import 'package:dio/dio.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/core/constants/api_constants.dart';
import 'package:smart_dress_shop_pos/core/storage/secure_storage.dart';
import 'package:smart_dress_shop_pos/core/errors/failure.dart';
import 'package:smart_dress_shop_pos/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<({UserModel user, String token})> login(String email, String password) async {
    try {
      final response = await _apiClient.instance.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      final String token = data['token'] as String;
      final user = UserModel.fromJson(data['user']);

      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUserData(user.toRawJson());

      return (user: user, token: token);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.instance.get(ApiConstants.me);
      final user = UserModel.fromJson(response.data['data']);
      await SecureStorageService.saveUserData(user.toRawJson());
      return user;
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.instance.post(ApiConstants.logout);
    } catch (_) {}
    await SecureStorageService.clearAll();
  }
}
