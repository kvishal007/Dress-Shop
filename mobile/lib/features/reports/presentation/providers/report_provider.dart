import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/reports/data/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRepository(apiClient);
});

class ReportState {
  final bool isLoading;
  final Map<String, dynamic>? salesData;
  final Map<String, dynamic>? profitLossData;
  final Map<String, dynamic>? inventoryData;
  final String? errorMessage;
  final String period;

  ReportState({
    this.isLoading = false,
    this.salesData,
    this.profitLossData,
    this.inventoryData,
    this.errorMessage,
    this.period = 'month',
  });

  ReportState copyWith({
    bool? isLoading,
    Map<String, dynamic>? salesData,
    Map<String, dynamic>? profitLossData,
    Map<String, dynamic>? inventoryData,
    String? errorMessage,
    String? period,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      salesData: salesData ?? this.salesData,
      profitLossData: profitLossData ?? this.profitLossData,
      inventoryData: inventoryData ?? this.inventoryData,
      errorMessage: errorMessage,
      period: period ?? this.period,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(ReportState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final sales = await _repository.getSales(period: state.period);
      final pl = await _repository.getProfitLoss(period: state.period);
      final inv = await _repository.getInventoryValuation();

      state = state.copyWith(
        isLoading: false,
        salesData: sales,
        profitLossData: pl,
        inventoryData: inv,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setPeriod(String period) {
    state = state.copyWith(period: period);
    loadReports();
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return ReportNotifier(repo);
});
