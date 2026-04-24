import 'package:effulgence26_mobile_app/core/demo/demo_data.dart';
import '../models/auth_response_model.dart';
import '../models/otp_response_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Demo implementation of [AuthRemoteDataSource].
/// All read operations return static mock data; write operations silently succeed.
class AuthDemoDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> getCurrentUser() async => DemoData.demoUser;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async =>
      DemoData.demoAuthResponse;

  @override
  Future<AuthResponseModel> googleLogin({required String idToken}) async =>
      DemoData.demoAuthResponse;

  @override
  Future<AuthResponseModel> googleRegister({
    required String idToken,
    required String mobile,
    required String collegeName,
    required String password,
    String? referralRegId,
  }) async =>
      DemoData.demoAuthResponse;

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async =>
      DemoData.demoAuthResponse;

  @override
  Future<OtpResponseModel> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async =>
      OtpResponseModel(message: 'OTP resent (demo mode)', step: 'verify');

  @override
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async =>
      DemoData.demoAuthResponse;

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  }) async =>
      DemoData.demoUser;

  @override
  Future<List<UserModel>> getAllUsers() async => [DemoData.demoUser];

  @override
  Future<UserModel> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  }) async =>
      DemoData.demoUser;

  @override
  Future<Map<String, dynamic>> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  }) async =>
      {'message': 'Status updated (demo mode)'};
}
