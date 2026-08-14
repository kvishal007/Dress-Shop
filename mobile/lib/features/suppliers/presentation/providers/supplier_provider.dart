import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/suppliers/data/supplier_repository.dart';
import 'package:smart_dress_shop_pos/features/suppliers/data/supplier_model.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupplierRepository(apiClient);
});

class SupplierState {
  final bool isLoading;
  final List<SupplierModel> suppliers;
  final String? errorMessage;

  SupplierState({
    this.isLoading = false,
    this.suppliers = const [],
    this.errorMessage,
  });

  SupplierState copyWith({
    bool? isLoading,
    List<SupplierModel>? suppliers,
    String? errorMessage,
  }) {
    return SupplierState(
      isLoading: isLoading ?? this.isLoading,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage,
    );
  }
}

class SupplierNotifier extends StateNotifier<SupplierState> {
  final SupplierRepository _repository;

  SupplierNotifier(this._repository) : super(SupplierState()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final suppliers = await _repository.getSuppliers();
      state = state.copyWith(isLoading: false, suppliers: suppliers);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addSupplier(Map<String, dynamic> data) async {
    try {
      final newSupplier = await _repository.createSupplier(data);
      state = state.copyWith(suppliers: [...state.suppliers, newSupplier]);
    } catch (e) {
      throw Exception('Failed to add supplier: $e');
    }
  }
}

final supplierProvider = StateNotifierProvider<SupplierNotifier, SupplierState>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return SupplierNotifier(repo);
});
