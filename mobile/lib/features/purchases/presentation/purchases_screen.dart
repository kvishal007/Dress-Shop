import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/formatters.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/purchases/presentation/providers/purchase_provider.dart';
import 'package:smart_dress_shop_pos/features/suppliers/presentation/providers/supplier_provider.dart';
import 'package:intl/intl.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});
  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  String _selectedTab = 'All';
  final _tabs = ['All', 'PENDING', 'RECEIVED', 'PARTIAL'];

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);

    final filteredPurchases = _selectedTab == 'All'
        ? purchaseState.purchases
        : purchaseState.purchases.where((p) => p.status == _selectedTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
      ),
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child: purchaseState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPurchases.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.shopping_bag_outlined,
                        title: 'No Purchase Orders',
                        message: 'Create a purchase order to receive stock from your suppliers.',
                      )
                    : ListView.builder(
                        itemCount: filteredPurchases.length,
                        itemBuilder: (context, index) {
                          final purchase = filteredPurchases[index];
                          final isPending = purchase.status == 'PENDING';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isPending ? AppColors.warning : Colors.transparent,
                                width: isPending ? 1 : 0,
                              )
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(purchase.poNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  _statusChip(purchase.status),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Supplier: ${purchase.supplierId['name'] ?? 'Unknown'}'),
                                    Text('Items: ${purchase.items.length} • Total: ${Formatters.formatCurrency(purchase.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Date: ${DateFormat('MMM dd, yyyy').format(purchase.createdAt)}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              trailing: isPending
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                                      onPressed: () => _receivePO(purchase.id),
                                      child: const Text('Receive', style: TextStyle(color: Colors.white)),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddPurchaseSheet(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      height: 44,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'PENDING': color = AppColors.warning; break;
      case 'RECEIVED': color = AppColors.accent; break;
      default: color = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _receivePO(String id) async {
    try {
      await ref.read(purchaseProvider.notifier).receivePurchase(id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PO Received and Stock Updated!'), backgroundColor: AppColors.accent));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    }
  }

  void _showAddPurchaseSheet() {
    String? selectedSupplierId;
    final qtyCtrl = TextEditingController(text: '1');
    final costCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final suppliers = ref.watch(supplierProvider).suppliers;
          return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Purchase Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSupplierId,
                  decoration: const InputDecoration(labelText: 'Supplier *'),
                  items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setSheetState(() => selectedSupplierId = v),
                ),
                const SizedBox(height: 12),
                const Text('Line Item (Simplified for Demo)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Price'))),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (selectedSupplierId == null || costCtrl.text.isEmpty) return;
                      setSheetState(() => isSaving = true);
                      
                      try {
                        // Hardcoding a generic product ID for the simplified form just to make the POST succeed.
                        // In reality, this would have a Product picker.
                        final items = [{
                          'productId': '60d5ec49f1b2c8b1f8e4e1a1', // placeholder objectId
                          'productName': 'Misc Items',
                          'sku': 'MISC-01',
                          'quantity': int.tryParse(qtyCtrl.text) ?? 1,
                          'costPrice': double.tryParse(costCtrl.text) ?? 0.0,
                          'subtotal': (int.tryParse(qtyCtrl.text) ?? 1) * (double.tryParse(costCtrl.text) ?? 0.0)
                        }];
                        
                        await ref.read(purchaseProvider.notifier).createPurchase({
                          'supplierId': selectedSupplierId,
                          'items': items,
                        });
                        await ref.read(purchaseProvider.notifier).loadPurchases();
                        
                        if (context.mounted) {
                          Navigator.pop(ctx);
                        }
                      } catch (e) {
                         setSheetState(() => isSaving = false);
                      }
                    },
                    child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Create PO'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
