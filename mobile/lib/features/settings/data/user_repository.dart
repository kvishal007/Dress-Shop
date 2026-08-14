import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<List<UserModel>> getUsers() async {
    final response = await _apiClient.instance.get('/api/v1/users');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.instance.post('/api/v1/auth/register', data: userData);
    return UserModel.fromJson(response.data['data']['user']);
  }

  Future<void> deactivateUser(String id) async {
    await _apiClient.instance.patch('/api/v1/users/$id/deactivate');
  }

  Future<void> resetPassword(String id, String newPassword) async {
    await _apiClient.instance.patch('/api/v1/users/$id/reset-password', data: {'newPassword': newPassword});
  }

  Future<void> updateRole(String id, String role) async {
    await _apiClient.instance.patch('/api/v1/users/$id/role', data: {'role': role});
  }
}
