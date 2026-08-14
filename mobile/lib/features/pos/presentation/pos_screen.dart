import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/providers/cart_provider.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/providers/checkout_provider.dart';
import 'package:smart_dress_shop_pos/features/products/presentation/providers/products_provider.dart';
import 'package:smart_dress_shop_pos/features/products/domain/models/product.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onScanBarcode() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (res is String && res.isNotEmpty && res != '-1') {
      _searchController.text = res;
      _searchAndAddProduct(res);
    }
  }

  void _searchAndAddProduct(String query) {
    final productsState = ref.read(productsProvider);
    if (productsState.products == null) return;
    
    final product = productsState.products!.firstWhere(
      (p) => p.sku.toLowerCase() == query.toLowerCase() || p.barcode?.toLowerCase() == query.toLowerCase() || p.name.toLowerCase().contains(query.toLowerCase()),
      orElse: () => Product(id: '', name: 'Not Found', sku: '', categoryName: '', price: 0, stockQuantity: 0, minStockLevel: 0, sizes: [], colors: [], status: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );

    if (product.id.isNotEmpty) {
      ref.read(cartProvider.notifier).addProduct(product);
      _searchController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${product.name}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product not found'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final productsState = ref.watch(productsProvider);
    final checkoutState = ref.watch(checkoutProvider);

    ref.listen<CheckoutState>(checkoutProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      } else if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful! Bill Generated.'), backgroundColor: Colors.green));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _onScanBarcode,
            tooltip: 'Scan Barcode',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Pane: Products & Search
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by Name, SKU or Scan Barcode',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onSubmitted: _searchAndAddProduct,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _onScanBarcode,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: productsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productsState.products == null || productsState.products!.isEmpty
                          ? const Center(child: Text('No products available'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: productsState.products!.length,
                              itemBuilder: (context, index) {
                                final product = productsState.products![index];
                                return InkWell(
                                  onTap: () {
                                    if (product.stockQuantity > 0) {
                                      ref.read(cartProvider.notifier).addProduct(product);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Stock')));
                                    }
                                  },
                                  child: Card(
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.checkroom, size: 48, color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('SKU: ${product.sku}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('₹${product.price}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                                  Text('${product.stockQuantity} in stock', style: TextStyle(fontSize: 10, color: product.stockQuantity > 0 ? Colors.green : Colors.red)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right Pane: Cart & Checkout
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.primary,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Current Bill', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: cartState.items.isEmpty
                        ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: cartState.items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = cartState.items[index];
                              return ListTile(
                                title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('₹${item.product.price} x ${item.quantity}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('₹${cartState.subtotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (5%):'),
                            Text('₹${cartState.taxAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('₹${cartState.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: cartState.items.isEmpty || checkoutState.isLoading
                                ? null
                                : () => ref.read(checkoutProvider.notifier).checkout('CASH'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: checkoutState.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Checkout (CASH)', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
