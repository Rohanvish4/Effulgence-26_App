import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/entity/user_entity.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../domain/repositories/admin_repository.dart'; // Import for DioException if needed, though ApiClient usually handles it

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers({int page = 1, int limit = 50}) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAllUsers(page: page, limit: limit);
        return Right(users);
      } catch (e) {
        // Handle specific exceptions or use a generic failure
        return Left(ServerFailure(message: e.toString())); 
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
