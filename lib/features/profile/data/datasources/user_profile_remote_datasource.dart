import 'dart:io';
import 'package:dio/dio.dart';
import 'package:effulgence26_mobile_app/features/profile/data/models/edit_response_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/referral_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> logout();

  Future<EditResponseModel> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    String? collegeName,
  });

  Future<Map<String, String>> getUploadUrl({required String fileType});
  Future<void> uploadImageToUrl(String uploadUrl, File file, String fileType);

  Future<void> submitPaymentDetails({
    required String utrNumber,
    required String paymentReceiptUrl,
  });

  Future<List<ReferralModel>> getMyReferrals();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.profile);
    // Handle nested 'user' object from API response
    final data = response.data['user'] ?? response.data;
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logout);
  }

  @override
  Future<EditResponseModel> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    String? collegeName,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (mobile != null) data['mobile'] = mobile;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (collegeName != null) data['collegeName'] = collegeName;

    final response = await apiClient.post(ApiConstants.profileEdit, data: data);
    return EditResponseModel.fromJson(response.data);
  }

  @override
  Future<Map<String, String>> getUploadUrl({required String fileType}) async {
    final response = await apiClient.post(
      '${ApiConstants.baseUrl}user/profile/upload-url',
      data: {'fileType': fileType, 'folder': 'userProfileImages'},
    );
    return {
      'uploadUrl': response.data['uploadUrl'],
      'publicUrl': response.data['publicUrl'],
    };
  }

  @override
  Future<void> uploadImageToUrl(
    String uploadUrl,
    File file,
    String fileType,
  ) async {
    final dio = Dio();
    await dio.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: await file.length(),
          "Content-Type": fileType,
        },
      ),
    );
  }

  @override
  Future<void> submitPaymentDetails({
    required String utrNumber,
    required String paymentReceiptUrl,
  }) async {
    await apiClient.post(
      '${ApiConstants.baseUrl}user/profile/submit-payment',
      data: {
        'utrNumber': utrNumber,
        'paymentReceiptUrl': paymentReceiptUrl,
      },
    );
  }

  @override
  Future<List<ReferralModel>> getMyReferrals() async {
    final response = await apiClient.get(ApiConstants.myReferrals);
    final data = response.data['referrals'] as List? ?? [];
    return data
        .map((e) => ReferralModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
