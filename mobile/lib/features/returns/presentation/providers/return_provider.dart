import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/returns/data/return_repository.dart';
import 'package:smart_dress_shop_pos/features/returns/data/return_model.dart';

final returnRepositoryProvider = Provider<ReturnRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReturnRepository(apiClient);
});

class ReturnState {
  final bool isLoading;
  final List<ReturnModel> returns;
  final String? errorMessage;

  ReturnState({
    this.isLoading = false,
    this.returns = const [],
    this.errorMessage,
  });

  ReturnState copyWith({
    bool? isLoading,
    List<ReturnModel>? returns,
    String? errorMessage,
  }) {
    return ReturnState(
      isLoading: isLoading ?? this.isLoading,
      returns: returns ?? this.returns,
      errorMessage: errorMessage,
    );
  }
}

class ReturnNotifier extends StateNotifier<ReturnState> {
  final ReturnRepository _repository;

  ReturnNotifier(this._repository) : super(ReturnState()) {
    loadReturns();
  }

  Future<void> loadReturns() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final returns = await _repository.getReturns();
      state = state.copyWith(isLoading: false, returns: returns);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> processReturn(Map<String, dynamic> data) async {
    try {
      final newReturn = await _repository.processReturn(data);
      state = state.copyWith(returns: [newReturn, ...state.returns]);
    } catch (e) {
      throw Exception('Failed to process return: $e');
    }
  }
}

final returnProvider = StateNotifierProvider<ReturnNotifier, ReturnState>((ref) {
  final repo = ref.watch(returnRepositoryProvider);
  return ReturnNotifier(repo);
});
