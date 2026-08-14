import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/providers/cart_provider.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/providers/checkout_provider.dart';
import 'package:smart_dress_shop_pos/features/products/presentation/providers/product_provider.dart';
import 'package:smart_dress_shop_pos/features/products/data/models/product_model.dart';
import 'package:smart_dress_shop_pos/features/customers/presentation/providers/customer_provider.dart';
import 'package:smart_dress_shop_pos/features/customers/data/customer_model.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';
import 'package:smart_dress_shop_pos/core/errors/failure.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/barcode_scanner_page.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _amountTenderedController =
      TextEditingController();

  String _paymentMethod = 'CASH';
  CustomerModel? _selectedCustomer;
  bool _showCustomerSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _amountTenderedController.dispose();
    super.dispose();
  }

  Future<void> _onScanBarcode() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );
    if (code == null || code.isEmpty) return;
    if (!mounted) return;
    await _scanAndAddProduct(code);
  }

  /// Looks up a scanned code against the backend (not the locally loaded
  /// product list) so the scanner always resolves to the authoritative
  /// product and stock count, then adds it to the cart.
  Future<void> _scanAndAddProduct(String code) async {
    try {
      final product =
          await ref.read(productRepositoryProvider).getProductByScanCode(code);
      if (!mounted) return;
      _addToCartWithFeedback(product);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_messageForScanError(e)),
            backgroundColor: Colors.red),
      );
    }
  }

  String _messageForScanError(Object error) {
    if (error is NetworkFailure) return 'Unable to connect to the server.';
    if (error is AuthFailure) {
      return 'Your session has expired. Please log in again.';
    }
    if (error is ServerFailure) {
      if (error.statusCode == 404) return 'No product found for this code.';
      if (error.statusCode == 403) {
        return 'You do not have permission to do this.';
      }
      return 'Something went wrong. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _searchAndAddProduct(String query) {
    final productsState = ref.read(productProvider);
    if (productsState.products.isEmpty) return;

    final product = productsState.products.firstWhere(
      (p) =>
          p.sku.toLowerCase() == query.toLowerCase() ||
          p.barcode?.toLowerCase() == query.toLowerCase() ||
          p.name.toLowerCase().contains(query.toLowerCase()),
      orElse: () => ProductModel(
          id: '',
          name: 'Not Found',
          sku: '',
          categoryName: '',
          price: 0,
          costPrice: 0,
          stockQuantity: 0,
          minStockLevel: 0,
          sizes: [],
          colors: [],
          status: ''),
    );

    if (product.id.isNotEmpty) {
      _addToCartWithFeedback(product);
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Product not found'), backgroundColor: Colors.red));
    }
  }

  /// Adds [product] to the cart and surfaces the outcome, including the
  /// case where the cart already holds all available stock.
  void _addToCartWithFeedback(ProductModel product) {
    final result = ref.read(cartProvider.notifier).addProduct(product);
    switch (result) {
      case AddToCartResult.added:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Added ${product.name}')));
      case AddToCartResult.outOfStock:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('This product is currently out of stock.'),
              backgroundColor: Colors.red),
        );
      case AddToCartResult.stockExceeded:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Only ${product.stockQuantity} units available.'),
              backgroundColor: Colors.red),
        );
    }
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Quick Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *')),
            const SizedBox(height: 8),
            TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone *')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              final newCust = await ref
                  .read(customerProvider.notifier)
                  .addCustomer(nameCtrl.text, phoneCtrl.text);
              if (newCust != null) {
                setState(() => _selectedCustomer = newCust);
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _showReceiptDialog(Map<String, dynamic> saleData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text('Receipt')),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Invoice: ${saleData['invoiceNumber']}')),
              const Divider(),
              ...(saleData['items'] as List).map((item) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                              '${item['productName']} (x${item['quantity']})')),
                      Text('₹${item['subtotal']}'),
                    ],
                  )),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tax:'),
                Text('₹${saleData['taxAmount']}')
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Discount:'),
                Text('-₹${saleData['discountAmount']}')
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${saleData['totalAmount']}',
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Payment Method:'),
                Text('${saleData['paymentMethod']}')
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Close & New Sale')),
          ElevatedButton(onPressed: () {}, child: const Text('Print')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final productsState = ref.watch(productProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final customerState = ref.watch(customerProvider);
    final authState = ref.watch(authProvider);

    final permissions = RolePermissions(authState.user?.role ?? 'VIEWER');

    ref.listen<CheckoutState>(checkoutProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      } else if (next.isSuccess && next.saleData != null) {
        _showReceiptDialog(next.saleData!);
        setState(() {
          _selectedCustomer = null;
          _amountTenderedController.clear();
          _discountController.clear();
        });
      }
    });

    double amountTendered =
        double.tryParse(_amountTenderedController.text) ?? 0;
    double changeDue = (amountTendered - cartState.total) > 0
        ? (amountTendered - cartState.total)
        : 0;

    // Phone-width screens can't fit the products grid and the bill side by
    // side, so the bill moves into a bottom sheet below this breakpoint.
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final productsPane = _buildProductsPane(productsState);
    final billPane = _buildBillPane(
      cartState: cartState,
      checkoutState: checkoutState,
      customerState: customerState,
      permissions: permissions,
      changeDue: changeDue,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _onScanBarcode),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 2, child: productsPane),
                const VerticalDivider(width: 1),
                Expanded(child: billPane),
              ],
            )
          : productsPane,
      bottomNavigationBar: isWide ? null : _buildCartBar(cartState, billPane),
    );
  }

  /// Compact bottom bar shown on narrow screens; opens the full bill sheet.
  Widget _buildCartBar(CartState cartState, Widget billPane) {
    final itemCount =
        cartState.items.fold<int>(0, (sum, item) => sum + item.quantity);
    return Material(
      color: AppColors.primary,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => FractionallySizedBox(
            heightFactor: 0.9,
            child: billPane,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    itemCount == 0
                        ? 'Cart is empty'
                        : '$itemCount item(s) in cart',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '₹${cartState.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPane(ProductState productsState) {
    return Column(
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20)),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : productsState.products.isEmpty
                  ? const Center(child: Text('No products available'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productsState.products.length,
                      itemBuilder: (context, index) {
                        final product = productsState.products[index];
                        return InkWell(
                          onTap: () => _addToCartWithFeedback(product),
                          child: Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    child: Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.checkroom,
                                            size: 48, color: Colors.grey))),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('SKU: ${product.sku}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('₹${product.price}',
                                              style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              '${product.stockQuantity} in stock',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      product.stockQuantity > 0
                                                          ? Colors.green
                                                          : Colors.red)),
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
    );
  }

  Widget _buildBillPane({
    required CartState cartState,
    required CheckoutState checkoutState,
    required CustomerState customerState,
    required RolePermissions permissions,
    required double changeDue,
  }) {
    return Container(
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
                Text('Current Bill',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Customer Selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _selectedCustomer != null
                ? ListTile(
                    leading: const Icon(Icons.person, color: AppColors.primary),
                    title: Text(_selectedCustomer!.name),
                    subtitle: Text(_selectedCustomer!.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selectedCustomer = null),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: 'Search Customer',
                                  prefixIcon: Icon(Icons.search)),
                              onChanged: (v) {
                                setState(
                                    () => _showCustomerSearch = v.isNotEmpty);
                                ref
                                    .read(customerProvider.notifier)
                                    .setSearchQuery(v);
                              },
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: _showAddCustomerDialog),
                        ],
                      ),
                      if (_showCustomerSearch &&
                          customerState.customers.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            itemCount: customerState.customers.length,
                            itemBuilder: (ctx, i) {
                              final c = customerState.customers[i];
                              return ListTile(
                                title: Text('${c.name} - ${c.phone}'),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = c;
                                    _showCustomerSearch = false;
                                  });
                                },
                              );
                            },
                          ),
                        )
                    ],
                  ),
          ),
          const Divider(height: 1),

          // Cart Items
          Expanded(
            child: cartState.items.isEmpty
                ? const Center(
                    child: Text('Cart is empty',
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return ListTile(
                        title: Text(item.product.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle:
                            Text('₹${item.product.price} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                      item.product.id, item.quantity - 1),
                            ),
                            Text('${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .updateQuantity(
                                      item.product.id, item.quantity + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Payment Method
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('CASH')),
                DropdownMenuItem(value: 'CARD', child: Text('CARD')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              ],
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
          ),

          // Cash Details
          if (_paymentMethod == 'CASH')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountTenderedController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Amount Tendered'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Change: ₹${changeDue.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          const Divider(),
          // Totals
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('₹${cartState.subtotal.toStringAsFixed(2)}')
                    ]),
                const SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax (5%):'),
                      Text('₹${cartState.taxAmount.toStringAsFixed(2)}')
                    ]),

                // Role-gated discount
                if (permissions.canApplyDiscount) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount (₹):'),
                      SizedBox(
                        width: 100,
                        height: 30,
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(4)),
                          onChanged: (v) {
                            final amount = double.tryParse(v) ?? 0.0;
                            ref.read(cartProvider.notifier).setDiscount(amount);
                          },
                        ),
                      )
                    ],
                  )
                ],
                const Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('₹${cartState.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary))
                    ]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        cartState.items.isEmpty || checkoutState.isLoading
                            ? null
                            : () {
                                ref.read(checkoutProvider.notifier).checkout(
                                    _paymentMethod,
                                    customerId: _selectedCustomer?.id);
                              },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: checkoutState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Complete Sale',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
