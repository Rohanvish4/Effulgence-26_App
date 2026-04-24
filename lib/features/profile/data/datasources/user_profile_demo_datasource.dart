import 'dart:io';
import 'package:effulgence26_mobile_app/core/demo/demo_data.dart';
import '../models/edit_response_model.dart';
import '../models/referral_model.dart';
import '../models/user_profile_model.dart';
import 'user_profile_remote_datasource.dart';

/// Demo implementation of [ProfileRemoteDataSource].
/// Returns static mock profile data; write operations silently succeed.
class ProfileDemoDataSource implements ProfileRemoteDataSource {
  @override
  Future<UserProfileModel> getProfile() async => DemoData.demoProfile;

  @override
  Future<void> logout() async {}

  @override
  Future<EditResponseModel> updateProfile({
    String? name,
    int? mobile,
    String? imageUrl,
    String? collegeName,
  }) async =>
      DemoData.demoEditResponse;

  @override
  Future<Map<String, String>> getUploadUrl({required String fileType}) async =>
      {'uploadUrl': '', 'publicUrl': ''};

  @override
  Future<void> uploadImageToUrl(
      String uploadUrl, File file, String fileType) async {}

  @override
  Future<void> submitPaymentDetails({
    required String utrNumber,
    required String paymentReceiptUrl,
  }) async {}

  @override
  Future<List<ReferralModel>> getMyReferrals() async => [];
}
