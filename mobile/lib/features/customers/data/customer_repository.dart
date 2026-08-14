import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'customer_model.dart';

class CustomerRepository {
  final ApiClient _apiClient;

  CustomerRepository(this._apiClient);

  Future<List<CustomerModel>> getCustomers({String? search}) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.instance.get('/customers', queryParameters: queryParams);
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => CustomerModel.fromJson(json)).toList();
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> customerData) async {
    final response = await _apiClient.instance.post('/customers', data: customerData);
    return CustomerModel.fromJson(response.data['data']);
  }
}
