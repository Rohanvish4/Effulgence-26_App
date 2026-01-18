import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String message;
  const AuthAuthenticated({required this.user, required this.message});
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}

/// OTP sent state (after signup, before verification)
class AuthOtpSent extends AuthState {
  final String message;
  final String email; // Store email for verification step

  const AuthOtpSent({required this.message, required this.email});
}

/// OTP verification success state
class AuthOtpVerified extends AuthState {
  final UserEntity user;
  final String message;

  const AuthOtpVerified({required this.user, required this.message});
}

/// Registration success state
class AuthRegistrationSuccess extends AuthState {
  final String message;
  final UserEntity user;

  const AuthRegistrationSuccess({required this.message, required this.user});
}

/// Profile update success state
class AuthProfileUpdated extends AuthState {
  final String message;
  final UserEntity user;

  const AuthProfileUpdated({required this.message, required this.user});
}

/// Users list loaded state
class AuthUsersLoaded extends AuthState {
  final List<UserEntity> users;

  const AuthUsersLoaded({required this.users});
}

/// User role updated state
class AuthUserRoleUpdated extends AuthState {
  final String message;
  final UserEntity user;

  const AuthUserRoleUpdated({required this.message, required this.user});
}

/// User status approved state
class AuthUserStatusApproved extends AuthState {
  final String message;
  final Map<String, dynamic> data;

  const AuthUserStatusApproved({required this.message, required this.data});
}
