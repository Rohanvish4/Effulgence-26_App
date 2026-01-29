import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class EditUserProfileRepository {
  Future<Either<Failure, UserProfileEntity>>
  getProfile(); // fail ya phir userProfileEntity
  Future<Either<Failure, EditResponseModel>> update({
    String? name,
    int? mobile,
    String? imageUrl,
  });
}
