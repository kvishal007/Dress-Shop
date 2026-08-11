import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _roleChip('Admin', 1, AppColors.warning),
                const SizedBox(width: 8),
                _roleChip('Manager', 1, AppColors.info),
                const SizedBox(width: 8),
                _roleChip('Cashier', 1, AppColors.accent),
                const SizedBox(width: 8),
                _roleChip('Staff', 0, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.manage_accounts_outlined,
              title: 'No Additional Users',
              message: 'Add cashiers, managers and stock staff accounts. Each user gets role-based access to the system.',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddUserSheet(context),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _roleChip(String role, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text(role, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showAddUserSheet(BuildContext context) {
    String selectedRole = 'CASHIER';
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
              const Text('Add New Staff User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'Full Name *')),
              const SizedBox(height: 12),
              TextField(keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address *')),
              const SizedBox(height: 12),
              TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Password *')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role *'),
                items: ['ADMIN', 'MANAGER', 'CASHIER', 'STOCK_STAFF', 'VIEWER']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setSheet(() => selectedRole = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Create User'))),
            ],
          ),
        ),
      ),
    );
  }
}
