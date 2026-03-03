import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/referral_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../datasources/user_profile_remote_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
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
  Future<Either<Failure, void>> logout() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EditResponseModel>> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    String? collegeName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final remoteProfile = await remoteDataSource.updateProfile(
        name: name,
        mobile: mobile,
        imageUrl: imageUrl,
        collegeName: collegeName,
      );
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
  Future<Either<Failure, String>> uploadProfileImage(File file) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // 1. Get Upload URL
      String fileName = file.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg'; // Default
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'jpg' || extension == 'jpeg') mimeType = 'image/jpeg';

      final urls = await remoteDataSource.getUploadUrl(fileType: mimeType);
      final uploadUrl = urls['uploadUrl']!;
      final publicUrl = urls['publicUrl']!;

      // 2. Upload File
      await remoteDataSource.uploadImageToUrl(uploadUrl, file, mimeType);

      // Return publicUrl
      return Right(publicUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitPaymentDetails({
    required File receiptImage,
    required String utrNumber,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // 1. Upload Receipt Image
      String fileName = receiptImage.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'jpg' || extension == 'jpeg') mimeType = 'image/jpeg';
      if (extension == 'pdf') mimeType = 'application/pdf';

      final urls = await remoteDataSource.getUploadUrl(fileType: mimeType);
      final uploadUrl = urls['uploadUrl']!;
      final publicUrl = urls['publicUrl']!;

      await remoteDataSource.uploadImageToUrl(
        uploadUrl,
        receiptImage,
        mimeType,
      );

      // 2. Submit Details
      await remoteDataSource.submitPaymentDetails(
        utrNumber: utrNumber,
        paymentReceiptUrl: publicUrl,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReferralEntity>>> getMyReferrals() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final referrals = await remoteDataSource.getMyReferrals();
      return Right(referrals);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
