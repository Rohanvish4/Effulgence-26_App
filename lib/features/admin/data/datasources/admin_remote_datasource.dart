import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entity/user_entity.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserEntity>> getAllUsers({int page = 1, int limit = 50});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UserEntity>> getAllUsers({int page = 1, int limit = 50}) async {
    final response = await apiClient.get(
      ApiConstants.users,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    // Assuming the API returns a list of users directly or inside a 'data' field
    // Adjust based on actual API response structure
    final data = response.data;
    List<dynamic> usersList;

    if (data is List) {
      usersList = data;
    } else if (data is Map<String, dynamic> && data.containsKey('users')) {
      usersList = data['users'];
    } else {
      usersList = [];
    }

    return usersList.map((json) => UserModel.fromJson(json)).toList();
  }
}
