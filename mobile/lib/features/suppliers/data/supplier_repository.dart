import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'supplier_model.dart';

class SupplierRepository {
  final ApiClient _apiClient;

  SupplierRepository(this._apiClient);

  Future<List<SupplierModel>> getSuppliers() async {
    final response = await _apiClient.instance.get('/api/v1/suppliers');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => SupplierModel.fromJson(json)).toList();
  }

  Future<SupplierModel> createSupplier(Map<String, dynamic> supplierData) async {
    final response = await _apiClient.instance.post('/api/v1/suppliers', data: supplierData);
    return SupplierModel.fromJson(response.data['data']);
  }
}
