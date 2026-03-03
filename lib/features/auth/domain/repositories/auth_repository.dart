import 'package:dartz/dartz.dart';

import 'package:effulgence26_mobile_app/core/errors/failures.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/auth_response_entity.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/otp_response_otp.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, AuthResponseEntity>> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  });

  Future<Either<Failure, AuthResponseEntity>> googleLogin({
    required String idToken,
  });

  Future<Either<Failure, AuthResponseEntity>> googleRegister({
    required String idToken,
    required String mobile,
    required String collegeName,
    required String password,
    String? referralRegId,
  });

  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, OtpResponseEntity>> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  });

  /// Login user
  Future<Either<Failure, AuthResponseEntity>> login({
    required String email,
    required String password,
  });

  /// Logout user
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  });

  /// Get all users (SUPER_ADMIN only)
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  /// Update user role (SUPER_ADMIN only)
  Future<Either<Failure, UserEntity>> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  });

  /// Approve/reject user status (ADMIN/SUPER_ADMIN)
  Future<Either<Failure, Map<String, dynamic>>> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  });

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get cached user
  Future<UserEntity?> getCachedUser();

  /// Save auth token
  Future<void> saveToken(String token);

  /// Get auth token
  Future<String?> getToken();

  /// Clear auth data
  Future<void> clearAuthData();
}
