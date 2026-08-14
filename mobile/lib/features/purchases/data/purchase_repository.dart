import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'purchase_model.dart';

class PurchaseRepository {
  final ApiClient _apiClient;

  PurchaseRepository(this._apiClient);

  Future<List<PurchaseModel>> getPurchases() async {
    final response = await _apiClient.instance.get('/api/v1/purchases');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => PurchaseModel.fromJson(json)).toList();
  }

  Future<PurchaseModel> createPurchase(Map<String, dynamic> purchaseData) async {
    final response = await _apiClient.instance.post('/api/v1/purchases', data: purchaseData);
    return PurchaseModel.fromJson(response.data['data']);
  }

  Future<PurchaseModel> receivePurchase(String purchaseId) async {
    final response = await _apiClient.instance.post('/api/v1/purchases/$purchaseId/receive');
    return PurchaseModel.fromJson(response.data['data']);
  }
}
