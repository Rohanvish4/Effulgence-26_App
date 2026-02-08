import 'package:effulgence26_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryImpl authRepositoryImpl;

  AuthCubit({required this.authRepositoryImpl}) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final result = await authRepositoryImpl.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (authResponse) {
        emit(
          AuthAuthenticated(
            user: authResponse.user!,
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
        emit(AuthError(message: failure.message));
      },
      (response) {
        // NEW: Check if this is OTP flow or direct registration
        if (response.user == null) {
          // OTP flow - user not created yet
          emit(AuthOtpSent(message: response.message, email: email));
        } else {
          // Direct registration (for backward compatibility)
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
      (authResponse) {
        if (authResponse.user != null) {
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
          debugPrint(' drvszAuthCubit:  OTP verified tsrbdbfdf,........ ');
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

    final result = await authRepositoryImpl.logout();

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
      },
      (_) {
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
      (user) {
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
        (user) {
          emit(AuthAuthenticated(user: user, message: 'Welcome back'));
        },
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
