import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/products/presentation/providers/product_provider.dart';
import 'package:smart_dress_shop_pos/features/inventory/presentation/providers/inventory_provider.dart';

import 'package:intl/intl.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});
  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(productProvider.notifier).setSearchQuery(_searchCtrl.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Search products by SKU or name...', prefixIcon: Icon(Icons.search, size: 20)),
            ),
          ),
          Expanded(
            child: productsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: productsState.products.length,
                    itemBuilder: (context, index) {
                      final product = productsState.products[index];
                      final isLowStock = product.stockQuantity <= 5;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isLowStock ? AppColors.warning : Colors.transparent,
                            width: isLowStock ? 2 : 0,
                          )
                        ),
                        child: ListTile(
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('SKU: ${product.sku}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLowStock ? AppColors.warning.withOpacity(0.1) : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Text(
                              '${product.stockQuantity} in stock',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isLowStock ? AppColors.warning : AppColors.textPrimary),
                            ),
                          ),
                          onTap: () => _showInventoryOptions(context, product.id, product.name, product.stockQuantity),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showInventoryOptions(BuildContext context, String productId, String productName, int currentStock) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage: $productName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_note, color: AppColors.primary),
              title: const Text('Adjust Stock Manually'),
              onTap: () {
                Navigator.pop(ctx);
                _showAdjustStockDialog(context, productId, currentStock);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: const Text('View Movement History'),
              onTap: () {
                Navigator.pop(ctx);
                _showMovementHistory(context, productId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, String productId, int currentStock) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Adjust Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Stock: $currentStock', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                decoration: const InputDecoration(labelText: 'Quantity Change (e.g. -2 or 5)'),
              ),
              const SizedBox(height: 12),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason (e.g. Damage, Audit)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                final change = int.tryParse(qtyCtrl.text);
                if (change == null || reasonCtrl.text.isEmpty) return;
                
                setState(() => isSaving = true);
                try {
                  await ref.read(inventoryProvider).adjustStock(productId, change, reasonCtrl.text);
                  await ref.read(productProvider.notifier).loadProductsAndCategories(); // Refresh list
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock Adjusted!'), backgroundColor: AppColors.accent));
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                    setState(() => isSaving = false);
                  }
                }
              },
              child: isSaving ? const CircularProgressIndicator() : const Text('Apply Adjustments'),
            ),
          ],
        ),
      )
    );
  }

  void _showMovementHistory(BuildContext context, String productId) async {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
    );

    try {
      final history = await ref.read(inventoryProvider).getMovementHistory(productId);
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Movement History'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: history.isEmpty 
              ? const Center(child: Text('No history found'))
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final isPositive = item.quantityChange > 0;
                    return ListTile(
                      leading: Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: isPositive ? AppColors.accent : AppColors.error),
                      title: Text('${isPositive ? '+' : ''}${item.quantityChange} (${item.type})'),
                      subtitle: Text('${item.reason}\n${DateFormat('MMM dd, yyyy HH:mm').format(item.createdAt)}'),
                      isThreeLine: true,
                    );
                  },
                ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }
}
