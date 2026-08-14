import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'settings_model.dart';

class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository(this._apiClient);

  Future<SettingsModel> getSettings() async {
    final response = await _apiClient.instance.get('/api/v1/settings');
    return SettingsModel.fromJson(response.data['data']);
  }

  Future<SettingsModel> updateSettings(Map<String, dynamic> settingsData) async {
    final response = await _apiClient.instance.patch('/api/v1/settings', data: settingsData);
    return SettingsModel.fromJson(response.data['data']);
  }
}
