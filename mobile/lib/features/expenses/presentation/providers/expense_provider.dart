import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/expenses/data/expense_repository.dart';
import 'package:smart_dress_shop_pos/features/expenses/data/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExpenseRepository(apiClient);
});

class ExpenseState {
  final bool isLoading;
  final List<ExpenseModel> expenses;
  final String? errorMessage;

  ExpenseState({
    this.isLoading = false,
    this.expenses = const [],
    this.errorMessage,
  });

  ExpenseState copyWith({
    bool? isLoading,
    List<ExpenseModel>? expenses,
    String? errorMessage,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseNotifier(this._repository) : super(ExpenseState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final expenses = await _repository.getExpenses();
      state = state.copyWith(isLoading: false, expenses: expenses);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    try {
      final newExpense = await _repository.createExpense(data);
      state = state.copyWith(expenses: [newExpense, ...state.expenses]);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return ExpenseNotifier(repo);
});
