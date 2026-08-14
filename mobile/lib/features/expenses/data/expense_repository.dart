import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'expense_model.dart';

class ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepository(this._apiClient);

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _apiClient.instance.get('/api/v1/expenses');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  Future<ExpenseModel> createExpense(Map<String, dynamic> expenseData) async {
    final response = await _apiClient.instance.post('/api/v1/expenses', data: expenseData);
    return ExpenseModel.fromJson(response.data['data']);
  }
}
