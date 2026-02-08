import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileEntity>>
  getProfile(); // fail ya phir userProfileEntity

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, EditResponseModel>> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    String? collegeName,
  });

  Future<Either<Failure, String>> uploadProfileImage(File file);

  Future<Either<Failure, void>> submitPaymentDetails({
    required File receiptImage,
    required String utrNumber,
  });
}
