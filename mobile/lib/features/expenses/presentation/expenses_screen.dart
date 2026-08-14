import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/formatters.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/expenses/presentation/providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});
  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _categories = ['Rent', 'Electricity', 'Salaries', 'Internet', 'Transport', 'Packaging', 'Advertising', 'Repairs', 'Other'];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);

    final filteredExpenses = _selectedCategory == 'All' 
        ? expenseState.expenses 
        : expenseState.expenses.where((e) => e.category == _selectedCategory).toList();

    final currentMonthTotal = expenseState.expenses
        .where((e) => e.date.month == DateTime.now().month && e.date.year == DateTime.now().year)
        .fold<double>(0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {})],
      ),
      body: Column(
        children: [
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
                    Text(Formatters.formatCurrency(currentMonthTotal), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
          Expanded(
            child: expenseState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredExpenses.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.payments_outlined,
                        title: 'No Expenses Recorded',
                        message: 'Track shop expenses like rent, electricity, salaries and more to calculate accurate net profit.',
                      )
                    : ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                              child: const Icon(Icons.receipt_long, color: Color(0xFF8B5CF6)),
                            ),
                            title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${DateFormat('MMM dd, yyyy').format(expense.date)} • ${expense.note}'),
                            trailing: Text(Formatters.formatCurrency(expense.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 16, fontFamily: 'monospace')),
                          );
                        },
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
    bool isSaving = false;

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
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / Notes *')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    final amount = double.tryParse(amountCtrl.text);
                    if (amount == null || amount <= 0 || descCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount and description'), backgroundColor: AppColors.error));
                      return;
                    }
                    
                    setSheet(() => isSaving = true);
                    try {
                      await ref.read(expenseProvider.notifier).addExpense({
                        'category': selectedCat,
                        'amount': amount,
                        'date': DateTime.now().toIso8601String(),
                        'note': descCtrl.text,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense logged successfully'), backgroundColor: AppColors.accent));
                        Navigator.pop(ctx);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                        setSheet(() => isSaving = false);
                      }
                    }
                  },
                  child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
