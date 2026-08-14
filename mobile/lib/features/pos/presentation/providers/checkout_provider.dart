import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/providers/cart_provider.dart';
import 'package:dio/dio.dart';

class CheckoutState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CheckoutState({this.isLoading = false, this.error, this.isSuccess = false});
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(CheckoutState());

  Future<void> checkout(String paymentMethod) async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      state = CheckoutState(error: 'Cart is empty');
      return;
    }

    state = CheckoutState(isLoading: true);

    try {
      final items = cartState.items.map((item) {
        return {
          'sku': item.product.sku,
          'quantity': item.quantity,
        };
      }).toList();

      final payload = {
        'items': items,
        'taxAmount': cartState.taxAmount,
        'discountAmount': cartState.discountAmount,
        'paymentMethod': paymentMethod,
      };

      final api = ref.read(apiClientProvider);
      await api.instance.post('/api/v1/sales', data: payload);

      ref.read(cartProvider.notifier).clearCart();
      state = CheckoutState(isSuccess: true);
    } on DioException catch (e) {
      final failure = ref.read(apiClientProvider).handleDioError(e);
      state = CheckoutState(error: failure.message);
    } catch (e) {
      state = CheckoutState(error: e.toString());
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
