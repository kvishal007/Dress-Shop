import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/purchases/data/purchase_repository.dart';
import 'package:smart_dress_shop_pos/features/purchases/data/purchase_model.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PurchaseRepository(apiClient);
});

class PurchaseState {
  final bool isLoading;
  final List<PurchaseModel> purchases;
  final String? errorMessage;

  PurchaseState({
    this.isLoading = false,
    this.purchases = const [],
    this.errorMessage,
  });

  PurchaseState copyWith({
    bool? isLoading,
    List<PurchaseModel>? purchases,
    String? errorMessage,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      purchases: purchases ?? this.purchases,
      errorMessage: errorMessage,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PurchaseRepository _repository;

  PurchaseNotifier(this._repository) : super(PurchaseState()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final purchases = await _repository.getPurchases();
      state = state.copyWith(isLoading: false, purchases: purchases);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> receivePurchase(String purchaseId) async {
    try {
      final updated = await _repository.receivePurchase(purchaseId);
      final newPurchases = state.purchases.map((p) => p.id == updated.id ? updated : p).toList();
      state = state.copyWith(purchases: newPurchases);
    } catch (e) {
      throw Exception('Failed to receive purchase: $e');
    }
  }

  Future<void> createPurchase(Map<String, dynamic> purchaseData) async {
    try {
      final newPurchase = await _repository.createPurchase(purchaseData);
      state = state.copyWith(purchases: [newPurchase, ...state.purchases]);
    } catch (e) {
      throw Exception('Failed to create purchase: $e');
    }
  }
}

final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return PurchaseNotifier(repo);
});
