import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entity/user_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers({int page = 1, int limit = 50});
}
