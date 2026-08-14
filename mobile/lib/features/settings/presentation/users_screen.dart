import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/providers/user_provider.dart';
import 'package:smart_dress_shop_pos/features/settings/data/user_model.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    // Calculate stats
    int adminCount = 0;
    int managerCount = 0;
    int cashierCount = 0;
    int staffCount = 0;
    
    for (var u in userState.users) {
      if (u.status != 'ACTIVE') continue;
      if (u.role == 'ADMIN') adminCount++;
      if (u.role == 'MANAGER') managerCount++;
      if (u.role == 'CASHIER') cashierCount++;
      if (u.role == 'STOCK_STAFF' || u.role == 'VIEWER') staffCount++;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _roleChip('Admin', adminCount, AppColors.warning),
                const SizedBox(width: 8),
                _roleChip('Manager', managerCount, AppColors.info),
                const SizedBox(width: 8),
                _roleChip('Cashier', cashierCount, AppColors.accent),
                const SizedBox(width: 8),
                _roleChip('Staff', staffCount, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
          Expanded(
            child: userState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userState.users.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.manage_accounts_outlined,
                        title: 'No Additional Users',
                        message: 'Add cashiers, managers and stock staff accounts. Each user gets role-based access to the system.',
                      )
                    : ListView.builder(
                        itemCount: userState.users.length,
                        itemBuilder: (context, index) {
                          final user = userState.users[index];
                          final isActive = user.status == 'ACTIVE';
                          final roleColor = RolePermissions(user.role).roleColor;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive ? roleColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                              child: Icon(Icons.person, color: isActive ? roleColor : Colors.grey),
                            ),
                            title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, decoration: isActive ? null : TextDecoration.lineThrough, color: isActive ? AppColors.textPrimary : AppColors.textMuted)),
                            subtitle: Text('${user.email}\nRole: ${RolePermissions(user.role).displayName} • Status: ${user.status}'),
                            isThreeLine: true,
                            trailing: isActive ? PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'reset') {
                                  _showResetPasswordDialog(context, ref, user);
                                } else if (val == 'deactivate') {
                                  _deactivateUser(context, ref, user);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'reset', child: Text('Reset Password')),
                                const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(color: AppColors.error))),
                              ],
                            ) : null,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddUserSheet(context, ref),
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

  void _showAddUserSheet(BuildContext context, WidgetRef ref) {
    String selectedRole = 'CASHIER';
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
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
              const Text('Add New Staff User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address *')),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password *')),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                    setSheet(() => isSaving = true);
                    
                    try {
                      await ref.read(userProvider.notifier).createUser({
                        'name': nameCtrl.text,
                        'email': emailCtrl.text,
                        'password': passCtrl.text,
                        'role': selectedRole,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User created successfully'), backgroundColor: AppColors.accent));
                        Navigator.pop(ctx);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                        setSheet(() => isSaving = false);
                      }
                    }
                  },
                  child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Create User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deactivateUser(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate ${user.name}? They will no longer be able to log in.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(userProvider.notifier).deactivateUser(user.id);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deactivated'), backgroundColor: AppColors.accent));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
              }
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  void _showResetPasswordDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final passCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Reset Password for ${user.name}'),
          content: TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (passCtrl.text.isEmpty) return;
                setState(() => isSaving = true);
                try {
                  await ref.read(userProvider.notifier).resetPassword(user.id, passCtrl.text);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully'), backgroundColor: AppColors.accent));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                    setState(() => isSaving = false);
                  }
                }
              },
              child: isSaving ? const CircularProgressIndicator() : const Text('Reset Password'),
            ),
          ],
        ),
      )
    );
  }
}
