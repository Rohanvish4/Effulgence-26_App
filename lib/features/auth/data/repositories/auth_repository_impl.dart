import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/auth_response_entity.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/otp_response_otp.dart';
import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthResponseEntity>> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        collegeName: collegeName,
        imageUrl: imageUrl,
      );

      // Save user data
      if (response.user != null) {
        await localDataSource.saveUser(response.user as UserModel);
      }

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, fieldErrors: e.fieldErrors),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save user data
      await localDataSource.saveUser(response.user as UserModel);

      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      // Still clear local data even if remote logout fail
      await localDataSource.clearAuthData();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    bool isConnected;
    try {
      isConnected = await networkInfo.isConnected.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
    } catch (_) {
      isConnected = false;
    }

    if (!isConnected) {
      // Try to get cached user
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.getCurrentUser().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw ServerException(message: 'Request timeout', statusCode: 408),
      );
      await localDataSource.saveUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.updateProfile(
        name: name,
        imageUrl: imageUrl,
        mobile: mobile,
        collegeName: collegeName,
      );
      await localDataSource.saveUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final users = await remoteDataSource.getAllUsers();
      return Right(users);
    } on UnauthorizedException catch (e) {
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await remoteDataSource.updateUserRole(
        targetUserId: targetUserId,
        newRole: newRole,
        remarks: remarks,
      );
      return Right(user);
    } on UnauthorizedException catch (e) {
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.approveUserStatus(
        userId: userId,
        status: status,
        remarks: remarks,
      );
      return Right(result);
    } on UnauthorizedException catch (e) {
      await localDataSource.clearAuthData();
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ForbiddenException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<void> saveToken(String token) async {
    await localDataSource.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<void> clearAuthData() async {
    await localDataSource.clearAuthData();
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.verifyOtp(email: email, otp: otp);
      // Save user data after successful OTP verification
      if (response.user != null) {
        await localDataSource.saveUser(response.user as UserModel);
      }
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, fieldErrors: e.fieldErrors),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OtpResponseEntity>> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.resendOtp(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        collegeName: collegeName,
        imageUrl: imageUrl,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, fieldErrors: e.fieldErrors),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
