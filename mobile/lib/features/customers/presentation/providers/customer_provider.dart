import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/customers/data/customer_repository.dart';
import 'package:smart_dress_shop_pos/features/customers/data/customer_model.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRepository(apiClient);
});

class CustomerState {
  final bool isLoading;
  final List<CustomerModel> customers;
  final String? errorMessage;
  final String searchQuery;

  CustomerState({
    this.isLoading = false,
    this.customers = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  CustomerState copyWith({
    bool? isLoading,
    List<CustomerModel>? customers,
    String? errorMessage,
    String? searchQuery,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final CustomerRepository _repository;

  CustomerNotifier(this._repository) : super(CustomerState()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final customers = await _repository.getCustomers(search: state.searchQuery);
      state = state.copyWith(isLoading: false, customers: customers);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadCustomers();
  }

  Future<CustomerModel?> addCustomer(String name, String phone) async {
    try {
      final newCustomer = await _repository.createCustomer({'name': name, 'phone': phone});
      state = state.copyWith(customers: [newCustomer, ...state.customers]);
      return newCustomer;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerNotifier(repo);
});
