import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/settings/data/audit_repository.dart';
import 'package:smart_dress_shop_pos/features/settings/data/audit_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuditRepository(apiClient);
});

class AuditState {
  final bool isLoading;
  final List<AuditLogModel> logs;
  final String? errorMessage;

  AuditState({
    this.isLoading = false,
    this.logs = const [],
    this.errorMessage,
  });

  AuditState copyWith({
    bool? isLoading,
    List<AuditLogModel>? logs,
    String? errorMessage,
  }) {
    return AuditState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
    );
  }
}

class AuditNotifier extends StateNotifier<AuditState> {
  final AuditRepository _repository;

  AuditNotifier(this._repository) : super(AuditState()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final logs = await _repository.getAuditLogs();
      state = state.copyWith(isLoading: false, logs: logs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final auditProvider = StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  final repo = ref.watch(auditRepositoryProvider);
  return AuditNotifier(repo);
});
