import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/suppliers/presentation/providers/supplier_provider.dart';

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierState = ref.watch(supplierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child: supplierState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : supplierState.suppliers.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.local_shipping_outlined,
                        title: 'No Suppliers Added',
                        message: 'Add your cloth suppliers to manage purchases, payables and payment terms.',
                      )
                    : ListView.builder(
                        itemCount: supplierState.suppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = supplierState.suppliers[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.store, color: Colors.white),
                            ),
                            title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${supplier.contactPerson} • ${supplier.phone}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Payables Due', style: TextStyle(fontSize: 10)),
                                Text('₹${supplier.payablesDue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontFamily: 'monospace')),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddSupplierSheet(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddSupplierSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    bool isSaving = false;

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
              const Text('Add New Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Company Name *')),
              const SizedBox(height: 12),
              TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contact Person *')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number *')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address (optional)')),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (nameCtrl.text.isEmpty || contactCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields'), backgroundColor: AppColors.error));
                        return;
                      }
                      
                      setSheetState(() => isSaving = true);
                      try {
                        await ref.read(supplierProvider.notifier).addSupplier({
                          'name': nameCtrl.text,
                          'contactPerson': contactCtrl.text,
                          'phone': phoneCtrl.text,
                          'email': emailCtrl.text.isEmpty ? null : emailCtrl.text,
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier saved successfully'), backgroundColor: AppColors.accent));
                          Navigator.pop(ctx);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                          setSheetState(() => isSaving = false);
                        }
                      }
                    },
                    child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Supplier'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
