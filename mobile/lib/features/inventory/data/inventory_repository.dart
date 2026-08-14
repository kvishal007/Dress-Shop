import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'inventory_model.dart';

class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository(this._apiClient);

  Future<void> adjustStock(String productId, int quantityChange, String reason) async {
    await _apiClient.instance.post('/api/v1/inventory/adjust', data: {
      'productId': productId,
      'quantityChange': quantityChange,
      'reason': reason,
    });
  }

  Future<List<InventoryMovementModel>> getMovementHistory(String productId) async {
    final response = await _apiClient.instance.get('/api/v1/inventory/product/$productId');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => InventoryMovementModel.fromJson(json)).toList();
  }
}
