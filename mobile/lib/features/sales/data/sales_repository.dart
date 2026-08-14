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
}
