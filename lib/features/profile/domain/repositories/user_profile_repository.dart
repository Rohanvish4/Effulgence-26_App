import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileEntity>>
  getProfile(); // fail ya phir userProfileEntity
  Future<Either<Failure, void>> logout(); // ya to fail ya to void
}
