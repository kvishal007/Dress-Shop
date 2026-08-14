import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/features/products/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartState {
  final List<CartItem> items;
  final double taxRate;
  final double discountAmount;

  CartState({
    this.items = const [],
    this.taxRate = 0.05, // 5% tax by default
    this.discountAmount = 0.0,
  });

  double get subtotal => items.fold(0, (total, item) => total + item.subtotal);
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount - discountAmount;

  CartState copyWith({
    List<CartItem>? items,
    double? taxRate,
    double? discountAmount,
  }) {
    return CartState(
      items: items ?? this.items,
      taxRate: taxRate ?? this.taxRate,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex].quantity++;
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(product: product)]);
    }
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }
    final newItems = state.items.map((item) {
      if (item.product.id == productId) {
        return CartItem(product: item.product, quantity: newQuantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: newItems);
  }

  void clearCart() {
    state = CartState();
  }

  void setDiscount(double amount) {
    state = state.copyWith(discountAmount: amount);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
