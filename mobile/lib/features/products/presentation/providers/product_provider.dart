import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import '../../data/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient);
});

class ProductState {
  final bool isLoading;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  ProductState({
    this.isLoading = false,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.errorMessage,
  });

  ProductState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(ProductState()) {
    loadProductsAndCategories();
  }

  Future<void> loadProductsAndCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts(
        search: state.searchQuery,
        category: state.selectedCategory,
      );
      state = state.copyWith(
        isLoading: false,
        categories: categories,
        products: products,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadProductsAndCategories();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProductsAndCategories();
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      await _repository.createProduct(data);
      await loadProductsAndCategories();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateProduct(id, data);
      await loadProductsAndCategories();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await loadProductsAndCategories();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductNotifier(repo);
});
