import 'package:effulgence26_mobile_app/core/errors/failures.dart';
import 'package:effulgence26_mobile_app/core/constants/app_env.dart';
import 'package:effulgence26_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/analytics_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryImpl authRepositoryImpl;
  final NotificationService notificationService;
  final AnalyticsService analytics = AnalyticsService.instance;

  AuthCubit({
    required this.authRepositoryImpl, 
    required this.notificationService,
  }) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        // Log login error
        analytics.logAuthError(
          errorType: 'login_failed',
          message: failure.message,
        );
        emit(AuthError(message: failure.message));
      },
      (authResponse) async {
        // Sync FCM Token
        debugPrint('AuthCubit: Login success, syncing FCM token...');
        await notificationService.syncFcmToken();
        
        
        // Track user in analytics
        final user = authResponse.user!;
        await analytics.identifyUser(
          userId: user.id,
          email: user.email,
          name: user.name,
          college: user.collegeName,
        );
        await analytics.logLogin(method: 'email_password');
        debugPrint(' User tracked in analytics: ${user.email}');
        
        emit(
          AuthAuthenticated(
            user: user,
            message: authResponse.message,
          ),
        );
      },
    );
  }

  /// send otp or register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    debugPrint('AuthCubit: Starting registration for $email');
    emit(AuthLoading());
    final result = await authRepositoryImpl.register(
      name: name,
      email: email,
      password: password,
      mobile: mobile,
      collegeName: collegeName,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) {
        analytics.logAuthError(
          errorType: 'registration_failed',
          message: failure.message,
        );
        emit(AuthError(message: failure.message));
      },
      (response) async {
        // NEW: Check if this is OTP flow or direct registration
        if (response.user == null) {
          // OTP flow - user not created yet
          await analytics.logEvent('registration_otp_sent', params: {
            'email': email,
            'college': collegeName,
          });
          emit(AuthOtpSent(message: response.message, email: email));
        } else {
          // Direct registration (for backward compatibility)
          // Sync FCM Token (though usually registration needs OTP verification first)
          debugPrint('AuthCubit: Registration success (direct), syncing FCM token...');
          await notificationService.syncFcmToken();

          final user = response.user!;
          await analytics.identifyUser(
            userId: user.id,
            email: user.email,
            name: user.name,
            college: user.collegeName,
          );
          await analytics.logSignUp(method: 'email');
          debugPrint('New user registered and tracked: $email');

          emit(
            AuthRegistrationSuccess(
              user: response.user!,
              message: response.message,
            ),
          );
        }
      },
    );
  }

  /// Verify OTP after registration
  Future<void> verifyOtp({required String email, required String otp}) async {
    debugPrint('AuthCubit: Verifying OTP for $email');
    emit(AuthLoading());
    final result = await authRepositoryImpl.verifyOtp(email: email, otp: otp);
    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (authResponse) async {
        if (authResponse.user != null) {
          // Sync FCM Token
          debugPrint('AuthCubit: OTP Verified, syncing FCM token...');
          await notificationService.syncFcmToken();

          final user = authResponse.user!;
          await analytics.identifyUser(
            userId: user.id,
            email: user.email,
            name: user.name,
            college: user.collegeName,
          );
          await analytics.logSignUp(method: 'email_otp');
          debugPrint('New user registered via OTP and tracked: ${user.email}');

          emit(
            AuthOtpVerified(
              user: authResponse.user!,
              message: authResponse.message,
            ),
          );
          emit(
            AuthRegistrationSuccess(
              message: authResponse.message,
              user: authResponse.user!,
            ),
          );
        } else {
          emit(AuthError(message: 'Verification failed'));
        }
      },
    );
  }

  /// Resend OTP
  Future<void> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    debugPrint('AuthCubit: Resending OTP for $email');
    emit(AuthLoading());
    final result = await authRepositoryImpl.resendOtp(
      name: name,
      email: email,
      password: password,
      mobile: mobile,
      collegeName: collegeName,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (otpResponse) {
        emit(AuthOtpSent(message: otpResponse.message, email: email));
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());

    // Clear FCM token before/during logout
    await notificationService.clearFcmToken();
    
    // Clear user from analytics
    await analytics.clearUser();

    final result = await authRepositoryImpl.logout();

    result.fold(
      (failure) {
        analytics.logAuthError(
          errorType: 'logout_failed',
          message: failure.message,
        );
        emit(AuthError(message: failure.message));
      },
      (_) {
        debugPrint('User logged out and cleared from analytics');
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.getCurrentUser();

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (user) async {
        // Sync FCM Token
        await notificationService.syncFcmToken();
        
        // Ensure user is identified in analytics on fresh session
        await analytics.identifyUser(
          userId: user.id,
          email: user.email,
          name: user.name,
          college: user.collegeName,
        );
        
        emit(AuthAuthenticated(user: user, message: 'Welcome back'));
      },
    );
  }

  Future<void> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  }) async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.updateProfile(
      name: name,
      imageUrl: imageUrl,
      mobile: mobile,
      collegeName: collegeName,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (user) {
        emit(
          AuthProfileUpdated(
            message: 'Profile updated successfully',
            user: user,
          ),
        );
      },
    );
  }

  Future<void> getAllUsers() async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.getAllUsers();

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (users) {
        emit(AuthUsersLoaded(users: users));
      },
    );
  }

  Future<void> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  }) async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.updateUserRole(
      targetUserId: targetUserId,
      newRole: newRole,
      remarks: remarks,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (user) {
        emit(
          AuthUserRoleUpdated(
            message: 'User role updated successfully',
            user: user,
          ),
        );
      },
    );
  }

  Future<void> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  }) async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.approveUserStatus(
      userId: userId,
      status: status,
      remarks: remarks,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (data) {
        emit(
          AuthUserStatusApproved(
            message: 'User status updated successfully',
            data: data,
          ),
        );
      },
    );
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepositoryImpl.isLoggedIn();
    if (isLoggedIn) {
      final result = await authRepositoryImpl.getCurrentUser();
      result.fold(
        (failure) {
          emit(const AuthUnauthenticated());
        },
        (user) async {
          // Sync FCM Token
          await notificationService.syncFcmToken();

          await analytics.identifyUser(
            userId: user.id,
            email: user.email,
            name: user.name,
            college: user.collegeName,
          );

          emit(AuthAuthenticated(user: user, message: 'Welcome back'));
        },
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // Google Sign In
  Future<void> googleLogin() async {
    emit(const AuthLoading());
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: AppEnv.googleServerClientId,
      );
      // Force account selection by signing out first
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled
        emit(const AuthInitial()); // Or error
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        emit(const AuthError(message: 'Failed to get ID Token from Google'));
        return;
      }

      final result = await authRepositoryImpl.googleLogin(idToken: idToken);
      
      result.fold(
        (failure) {
          if (failure is ServerFailure && failure.statusCode == 404) {
             // User not registered
             emit(GoogleUserNotRegistered(
               idToken: idToken,
               email: googleUser.email,
               name: googleUser.displayName,
               photoUrl: googleUser.photoUrl,
             ));
          } else {
             emit(AuthError(message: failure.message));
          }
        },
        (authResponse) async {
          // Sync FCM Token
          await notificationService.syncFcmToken();

          final user = authResponse.user!;
          await analytics.identifyUser(
            userId: user.id,
            email: user.email,
            name: user.name,
            college: user.collegeName,
          );
          await analytics.logLogin(method: 'google');
          debugPrint('Google login tracked: ${user.email}');

          emit(
            AuthAuthenticated(
              user: authResponse.user!,
              message: authResponse.message,
            ),
          );
        },
      );

    } catch (e) {
      debugPrint('Google Sign In Exception: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> googleRegister({
    required String idToken,
    required String mobile,
    required String collegeName,
    required String password,
    String? referralRegId,
  }) async {
    emit(const AuthLoading());
    final result = await authRepositoryImpl.googleRegister(
      idToken: idToken,
      mobile: mobile,
      collegeName: collegeName,
      password: password,
      referralRegId: referralRegId,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (authResponse) async {
        // Sync FCM Token
        await notificationService.syncFcmToken();

        final user = authResponse.user!;
        await analytics.identifyUser(
          userId: user.id,
          email: user.email,
          name: user.name,
          college: user.collegeName,
        );
        await analytics.logSignUp(method: 'google');
        debugPrint('Google register tracked: ${user.email}');

        emit(
          AuthAuthenticated(
            user: authResponse.user!,
            message: authResponse.message,
          ),
        );
      },
    );
  }

  UserEntity? get currentUser {
    final s = state;
    if (s is AuthAuthenticated) return s.user;
    if (s is AuthRegistrationSuccess) return s.user;
    if (s is AuthOtpVerified) return s.user;
    if (s is AuthProfileUpdated) return s.user;
    return null;
  }
}
