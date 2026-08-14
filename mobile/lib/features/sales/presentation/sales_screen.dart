import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/sales/presentation/providers/sales_provider.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';
import 'package:intl/intl.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  void _showReceiptDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> saleData) {
    final user = ref.read(authProvider).user;
    final canVoid = user != null && RolePermissions(user.role).canVoidSales;
    final isVoided = saleData['status'] == 'VOIDED';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text('Receipt Reprint')),
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
                  Expanded(child: Text('${item['productName']} (x${item['quantity']})')),
                  Text('₹${item['subtotal']}'),
                ],
              )),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax:'), Text('₹${saleData['taxAmount']}')]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Discount:'), Text('-₹${saleData['discountAmount']}')]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)), Text('₹${saleData['totalAmount']}', style: const TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Payment Method:'), Text('${saleData['paymentMethod']}')]),
              if (isVoided)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: Text('VOIDED', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 18))),
                ),
            ],
          ),
        ),
        actions: [
          if (canVoid && !isVoided)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmVoidSale(context, ref, saleData['id'], saleData['invoiceNumber']);
              },
              child: const Text('Void Sale', style: TextStyle(color: AppColors.error)),
            ),
          TextButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Close')),
          ElevatedButton(onPressed: () {}, child: const Text('Print')),
        ],
      ),
    );
  }

  void _confirmVoidSale(BuildContext context, WidgetRef ref, String saleId, String invoiceNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Void Sale', style: TextStyle(color: AppColors.error)),
        content: Text('Are you sure you want to void $invoiceNumber? This action is irreversible, items will be restocked, and the action will be audited.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(salesProvider.notifier).voidSale(saleId);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Voided'), backgroundColor: AppColors.accent));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Confirm Void', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesProvider);
    final dateStr = salesState.selectedDate != null 
        ? DateFormat('yyyy-MM-dd').format(salesState.selectedDate!) 
        : 'All Time';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: salesState.selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                ref.read(salesProvider.notifier).setDate(date);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                Text('Showing sales for: $dateStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: salesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : salesState.sales.isEmpty
                    ? const Center(child: Text('No sales found for this date'))
                    : ListView.builder(
                        itemCount: salesState.sales.length,
                        itemBuilder: (context, index) {
                          final sale = salesState.sales[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.receipt, color: Colors.white),
                              ),
                              title: Text(sale.invoiceNumber, style: TextStyle(fontWeight: FontWeight.bold, decoration: sale.status == 'VOIDED' ? TextDecoration.lineThrough : null)),
                              subtitle: Text('${sale.items.length} items • ${sale.paymentMethod}'),
                              trailing: Text('₹${sale.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: sale.status == 'VOIDED' ? AppColors.textMuted : AppColors.primary)),
                              onTap: () {
                                _showReceiptDialog(context, ref, {
                                  'id': sale.id,
                                  'invoiceNumber': sale.invoiceNumber,
                                  'items': sale.items.map((i) => {
                                    'productName': i.productName,
                                    'quantity': i.quantity,
                                    'subtotal': i.subtotal,
                                  }).toList(),
                                  'taxAmount': sale.taxAmount,
                                  'discountAmount': sale.discountAmount,
                                  'totalAmount': sale.totalAmount,
                                  'paymentMethod': sale.paymentMethod,
                                  'status': sale.status,
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
