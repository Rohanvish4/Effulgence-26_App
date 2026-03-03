import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [user, message];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// OTP sent state (after signup, before verification)
class AuthOtpSent extends AuthState {
  final String message;
  final String email; // Store email for verification step

  const AuthOtpSent({required this.message, required this.email});

  @override
  List<Object?> get props => [message, email];
}

/// OTP verification success state
class AuthOtpVerified extends AuthState {
  final UserEntity user;
  final String message;

  const AuthOtpVerified({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

/// Registration success state
class AuthRegistrationSuccess extends AuthState {
  final String message;
  final UserEntity user;

  const AuthRegistrationSuccess({required this.message, required this.user});

  @override
  List<Object?> get props => [message, user];
}

/// Profile update success state
class AuthProfileUpdated extends AuthState {
  final String message;
  final UserEntity user;

  const AuthProfileUpdated({required this.message, required this.user});

  @override
  List<Object?> get props => [message, user];
}

/// Users list loaded state
class AuthUsersLoaded extends AuthState {
  final List<UserEntity> users;

  const AuthUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

/// User role updated state
class AuthUserRoleUpdated extends AuthState {
  final String message;
  final UserEntity user;

  const AuthUserRoleUpdated({required this.message, required this.user});

  @override
  List<Object?> get props => [message, user];
}

/// User status approved state
class AuthUserStatusApproved extends AuthState {
  final String message;
  final Map<String, dynamic> data;

  const AuthUserStatusApproved({required this.message, required this.data});

  @override
  List<Object?> get props => [message, data];
}

class GoogleUserNotRegistered extends AuthState {
  final String idToken;
  final String email;
  final String? name;
  final String? photoUrl;

  const GoogleUserNotRegistered({
    required this.idToken,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [idToken, email, name, photoUrl];
}
