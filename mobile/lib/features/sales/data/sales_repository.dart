import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'sale_model.dart';

class SalesRepository {
  final ApiClient _apiClient;

  SalesRepository(this._apiClient);

  Future<List<SaleModel>> getSales({String? date}) async {
    final Map<String, dynamic> queryParams = {};
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    final response = await _apiClient.instance.get('/api/v1/sales', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => SaleModel.fromJson(json)).toList();
  }

  Future<SaleModel> createSale(Map<String, dynamic> saleData) async {
    final response = await _apiClient.instance.post('/api/v1/sales', data: saleData);
    return SaleModel.fromJson(response.data['data']);
  }

  Future<void> voidSale(String id) async {
    await _apiClient.instance.patch('/api/v1/sales/$id/void');
  }
}
