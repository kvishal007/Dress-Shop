import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/features/sales/presentation/providers/sales_provider.dart';
import 'package:intl/intl.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  void _showReceiptDialog(BuildContext context, Map<String, dynamic> saleData) {
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
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('Close')),
          ElevatedButton(onPressed: () {}, child: const Text('Print')),
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
                              title: Text(sale.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${sale.items.length} items • ${sale.paymentMethod}'),
                              trailing: Text('₹${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                              onTap: () {
                                _showReceiptDialog(context, {
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
