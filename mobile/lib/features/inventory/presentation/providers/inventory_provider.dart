import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/inventory/data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRepository(apiClient);
});

// For simply holding the inventory methods. Product loading is handled by productsProvider.
final inventoryProvider = Provider<InventoryRepository>((ref) {
  return ref.watch(inventoryRepositoryProvider);
});
