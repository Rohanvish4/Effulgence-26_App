import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> logout();
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
}
