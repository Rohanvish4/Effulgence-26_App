import 'package:effulgence26_mobile_app/core/demo/demo_data.dart';
import '../../../auth/domain/entity/user_entity.dart';
import 'admin_remote_datasource.dart';

/// Demo implementation of [AdminRemoteDataSource].
class AdminDemoDataSource implements AdminRemoteDataSource {
  @override
  Future<List<UserEntity>> getAllUsers({int page = 1, int limit = 50}) async =>
      DemoData.mockUsers;
}
