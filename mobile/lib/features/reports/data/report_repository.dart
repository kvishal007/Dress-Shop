import 'package:smart_dress_shop_pos/core/network/api_client.dart';

class ReportRepository {
  final ApiClient _apiClient;

  ReportRepository(this._apiClient);

  Future<Map<String, dynamic>> getSales({String period = 'month'}) async {
    final response = await _apiClient.instance.get('/api/v1/reports/sales?period=$period');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfitLoss({String period = 'month'}) async {
    final response = await _apiClient.instance.get('/api/v1/reports/profit-loss?period=$period');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getInventoryValuation() async {
    final response = await _apiClient.instance.get('/api/v1/reports/inventory-valuation');
    return response.data['data'] as Map<String, dynamic>;
  }
}
