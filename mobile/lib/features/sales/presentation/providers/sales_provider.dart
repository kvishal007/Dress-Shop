import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/sales/data/sales_repository.dart';
import 'package:smart_dress_shop_pos/features/sales/data/sale_model.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalesRepository(apiClient);
});

class SalesState {
  final bool isLoading;
  final List<SaleModel> sales;
  final String? errorMessage;
  final DateTime? selectedDate;

  SalesState({
    this.isLoading = false,
    this.sales = const [],
    this.errorMessage,
    this.selectedDate,
  });

  SalesState copyWith({
    bool? isLoading,
    List<SaleModel>? sales,
    String? errorMessage,
    DateTime? selectedDate,
  }) {
    return SalesState(
      isLoading: isLoading ?? this.isLoading,
      sales: sales ?? this.sales,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class SalesNotifier extends StateNotifier<SalesState> {
  final SalesRepository _repository;

  SalesNotifier(this._repository) : super(SalesState(selectedDate: DateTime.now())) {
    loadSales();
  }

  Future<void> loadSales() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dateStr = state.selectedDate?.toIso8601String().split('T')[0];
      final sales = await _repository.getSales(date: dateStr);
      state = state.copyWith(isLoading: false, sales: sales);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadSales();
  }

  Future<void> voidSale(String id) async {
    try {
      await _repository.voidSale(id);
      loadSales();
    } catch (e) {
      throw Exception('Failed to void sale: $e');
    }
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  return SalesNotifier(repo);
});
