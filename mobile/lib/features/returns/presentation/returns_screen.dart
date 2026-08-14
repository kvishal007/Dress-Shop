import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/formatters.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/returns/presentation/providers/return_provider.dart';
import 'package:intl/intl.dart';

class ReturnsScreen extends ConsumerWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnState = ref.watch(returnProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Returns & Refunds')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Invoice or Customer...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child: returnState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : returnState.returns.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.keyboard_return,
                        title: 'No Returns Processed',
                        message: 'Process refunds and exchanges here. Inventory will be restocked automatically if selected.',
                      )
                    : ListView.builder(
                        itemCount: returnState.returns.length,
                        itemBuilder: (context, index) {
                          final returnData = returnState.returns[index];
                          return ListTile(
                            leading: const CircleAvatar(backgroundColor: AppColors.error, child: Icon(Icons.keyboard_return, color: Colors.white)),
                            title: Text('Invoice: ${returnData.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${DateFormat('MMM dd, yyyy HH:mm').format(returnData.createdAt)} • ${returnData.reason}'),
                            trailing: Text('-${Formatters.formatCurrency(returnData.totalRefund)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 16, fontFamily: 'monospace')),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.error,
        onPressed: () => _showProcessReturnSheet(context, ref),
        icon: const Icon(Icons.assignment_return, color: Colors.white),
        label: const Text('New Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showProcessReturnSheet(BuildContext context, WidgetRef ref) {
    final invoiceCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final refundCtrl = TextEditingController();
    bool isSaving = false;
    bool restock = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Process New Return', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: invoiceCtrl, decoration: const InputDecoration(labelText: 'Original Invoice Number *')),
              const SizedBox(height: 12),
              TextField(controller: refundCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Refund Amount *')),
              const SizedBox(height: 12),
              TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason for Return *')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: restock, onChanged: (v) => setSheetState(() => restock = v ?? true), activeColor: AppColors.error),
                  const Text('Restock returned items back to inventory'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: isSaving ? null : () async {
                    if (invoiceCtrl.text.isEmpty || reasonCtrl.text.isEmpty || refundCtrl.text.isEmpty) return;
                    setSheetState(() => isSaving = true);
                    
                    try {
                      // Again, using simplified items for the return process for demo
                      final items = [{
                        'productId': '60d5ec49f1b2c8b1f8e4e1a1', // placeholder
                        'productName': 'Returned Item',
                        'sku': 'RET-01',
                        'quantity': 1,
                        'refundAmount': double.tryParse(refundCtrl.text) ?? 0.0,
                        'restock': restock
                      }];

                      await ref.read(returnProvider.notifier).processReturn({
                        'invoiceNumber': invoiceCtrl.text,
                        'reason': reasonCtrl.text,
                        'items': items,
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return processed!'), backgroundColor: AppColors.error));
                        Navigator.pop(ctx);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                        setSheetState(() => isSaving = false);
                      }
                    }
                  },
                  child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Process Return', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
