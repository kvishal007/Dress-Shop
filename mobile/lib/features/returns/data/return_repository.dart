import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'return_model.dart';

class ReturnRepository {
  final ApiClient _apiClient;

  ReturnRepository(this._apiClient);

  Future<List<ReturnModel>> getReturns() async {
    final response = await _apiClient.instance.get('/api/v1/returns');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => ReturnModel.fromJson(json)).toList();
  }

  Future<ReturnModel> processReturn(Map<String, dynamic> returnData) async {
    final response = await _apiClient.instance.post('/api/v1/returns', data: returnData);
    return ReturnModel.fromJson(response.data['data']);
  }
}
