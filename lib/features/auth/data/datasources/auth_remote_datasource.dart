import 'package:dio/dio.dart';
import 'package:effulgence26_mobile_app/core/errors/exceptions.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/otp_response_model.dart';
import '../models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  });

  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<OtpResponseModel> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  /// Get all users (SUPER_ADMIN only)
  Future<List<UserModel>> getAllUsers();

  /// Update user role (SUPER_ADMIN only)
  Future<UserModel> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  });

  /// Approve/reject user status (ADMIN/SUPER_ADMIN)
  Future<Map<String, dynamic>> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  });

  Future<UserModel> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  });

  Future<AuthResponseModel> googleLogin({
    required String idToken,
  });

  Future<AuthResponseModel> googleRegister({
    required String idToken,
    required String mobile,
    required String collegeName,
    required String password,
  });
}

/// Auth remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'mobile': mobile,
        'collegeName': collegeName,
        if (imageUrl != null)
          if (imageUrl.startsWith('http'))
            'imageUrl': imageUrl
          else
            'imageUrl': await MultipartFile.fromFile(imageUrl),
      });

      final response = await apiClient.post(
        ApiConstants.signup,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return AuthResponseModel.fromJson(response.data);
    } on ServerException catch (e) {
      if (e.statusCode == 409 &&
          (e.message.contains('OTP already sent') ||
              e.message.contains('User already exists'))) {
        // Treat as OTP sent success for navigation
        return AuthResponseModel(user: null, message: e.message);
      }
      rethrow;
    }
  }

  @override
  Future<OtpResponseModel> resendOtp({
    required String name,
    required String email,
    required String password,
    required int mobile,
    required String collegeName,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile.toString(), // Ensure mobile is string validation passes
      'collegeName': collegeName,
    };

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    final response = await apiClient.post(ApiConstants.resendOtp, data: data);
    return OtpResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiClient.post(
      ApiConstants.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.profile);
    return UserModel.fromJson(response.data['user'] ?? response.data);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await apiClient.get(ApiConstants.users);
    final data = response.data['users'] ?? response.data;
    if (data is List) {
      return data
          .map<UserModel>((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<UserModel> updateUserRole({
    required String targetUserId,
    required String newRole,
    String? remarks,
  }) async {
    final response = await apiClient.patch(
      ApiConstants.updateRole,
      data: {
        'targetUserId': targetUserId,
        'newRole': newRole,
        if (remarks != null) 'remarks': remarks,
      },
    );

    return UserModel.fromJson(response.data['user'] ?? response.data);
  }

  @override
  Future<Map<String, dynamic>> approveUserStatus({
    required String userId,
    required String status,
    String? remarks,
  }) async {
    final response = await apiClient.patch(
      ApiConstants.approveStatus,
      data: {
        'userId': userId,
        'status': status,
        if (remarks != null) 'remarks': remarks,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? imageUrl,
    int? mobile,
    String? collegeName,
  }) async {
    final response = await apiClient.post(
      ApiConstants.profileEdit,
      data: {
        if (name != null) 'name': name,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (mobile != null) 'mobile': mobile,
        if (collegeName != null) 'collegeName': collegeName,
      },
    );

    return UserModel.fromJson(response.data['user'] ?? response.data);
  }

  @override
  Future<AuthResponseModel> googleLogin({
    required String idToken,
  }) async {
    try {
      final response = await apiClient.post(
        '/user/auth/google-login',
        data: {'idToken': idToken},
      );
      return AuthResponseModel.fromJson(response.data);
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        // User not found, .. registration
        rethrow;
      }
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> googleRegister({
    required String idToken,
    required String mobile,
    required String collegeName,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/user/auth/google-register',
      data: {
        'idToken': idToken,
        'mobile': mobile,
        'collegeName': collegeName,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }
}
