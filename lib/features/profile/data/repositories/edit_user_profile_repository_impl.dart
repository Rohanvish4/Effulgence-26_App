import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/profile/data/datasources/edit_user_profile_remote_datasource.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import 'package:effulgence26_mobile_app/features/profile/domain/entities/EditResponseEntity.dart';
import 'package:effulgence26_mobile_app/features/profile/domain/repositories/edit_user_profile_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../datasources/user_profile_remote_datasource.dart';

class EditUserProfileRepositoryImpl implements EditUserProfileRepository {
  final EditProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EditUserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final remoteProfile = await remoteDataSource.getProfile();
      return Right(remoteProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(message: e.message, fieldErrors: e.fieldErrors),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, EditResponseModel>> update({
    String? name,
    int? mobile,
    String? imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.update(
        name: name,
        mobile: mobile,
        imageUrl: imageUrl,
      );

      // Save user data

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
