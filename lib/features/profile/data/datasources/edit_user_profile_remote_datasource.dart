import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/EditResponseEntity.dart';
import '../models/user_profile_model.dart';

abstract class EditProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<EditResponseModel> update({
     String? name,
     int? mobile,
    String? imageUrl,
  });
}

class EditProfileRemoteDataSourceImpl implements EditProfileRemoteDataSource {
  final ApiClient apiClient;

  EditProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.profile);
    // Handle nested 'user' object from API response
    final data = response.data['user'] ?? response.data;
    return UserProfileModel.fromJson(data);
  }
  @override
  Future<EditResponseModel> update({
     String? name,
     int? mobile,
    String? imageUrl,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.profileEdit,
        data: {
          if (name != null) 'name': name,
          if (mobile != null) 'mobile': mobile,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );


      return EditResponseModel.fromJson(response.data);
    } on ServerException catch (e) {

      rethrow;
    }
  }

}
