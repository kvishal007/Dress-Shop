import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/formatters.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/shared/widgets/coming_soon_banner.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _categories = ['Rent', 'Electricity', 'Salaries', 'Internet', 'Transport', 'Packaging', 'Advertising', 'Repairs', 'Other'];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {})],
      ),
      body: Column(
        children: [
          const ComingSoonBanner(),
          // Monthly total banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Month\'s Total', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(Formatters.formatCurrency(0), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.payments_outlined, color: Colors.white54, size: 36),
              ],
            ),
          ),
          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', ..._categories].map((cat) {
                final sel = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppColors.textSecondary)),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.payments_outlined,
              title: 'No Expenses Recorded',
              message: 'Track shop expenses like rent, electricity, salaries and more to calculate accurate net profit.',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5CF6),
        onPressed: () => _showAddExpenseSheet(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddExpenseSheet() {
    String selectedCat = _categories[0];
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSheet(() => selectedCat = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ ')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: 'Cash',
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['Cash', 'UPI', 'Bank Transfer', 'Card'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / Notes')),
              const SizedBox(height: 20),
              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving Expenses is coming soon!')));
                  Navigator.pop(ctx);
                },
                child: const Text('Save Expense'),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
