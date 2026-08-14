import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'audit_model.dart';

class AuditRepository {
  final ApiClient _apiClient;

  AuditRepository(this._apiClient);

  Future<List<AuditLogModel>> getAuditLogs() async {
    final response = await _apiClient.instance.get('/api/v1/audit');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => AuditLogModel.fromJson(json)).toList();
  }
}
