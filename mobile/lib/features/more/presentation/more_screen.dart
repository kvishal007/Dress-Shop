import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final perms = RolePermissions(authState.user?.role ?? 'CASHIER');
    final sections = _buildSections(perms);

    return Scaffold(
      appBar: AppBar(title: const Text('More Modules')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  section['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              ...(section['items'] as List<Map<String, dynamic>>).map(
                (item) => _buildMenuItem(context, item),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
          ),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(item['subtitle'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onTap: () {
            final route = item['route'] as String?;
            if (route != null) context.push(route);
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildSections(RolePermissions perms) {
    final sections = <Map<String, dynamic>>[];

    // POS & Sales
    if (perms.canAccessCustomers || perms.canProcessReturns) {
      sections.add({
        'title': 'POS & TRANSACTIONS',
        'items': [
          if (perms.canAccessCustomers)
            {'title': 'Customers', 'subtitle': 'Customer profiles, purchase history & credit', 'icon': Icons.people_outline, 'color': const Color(0xFF3B82F6), 'route': '/customers'},
          if (perms.canProcessReturns)
            {'title': 'Returns & Exchanges', 'subtitle': 'Process returns, refunds and exchanges', 'icon': Icons.assignment_return_outlined, 'color': AppColors.warning, 'route': '/returns'},
        ],
      });
    }

    // Inventory & Procurement
    if (perms.canAccessInventory || perms.canAccessSuppliers || perms.canAccessPurchases) {
      sections.add({
        'title': 'INVENTORY & PROCUREMENT',
        'items': [
          if (perms.canAddProducts)
            {'title': 'Products', 'subtitle': 'Clothing items with variants, SKU & barcode', 'icon': Icons.checkroom_outlined, 'color': AppColors.accentDark, 'route': '/products'},
          if (perms.canAccessInventory)
            {'title': 'Stock Management', 'subtitle': 'Current stock levels & movement history', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFF10B981), 'route': '/inventory'},
          if (perms.canAccessPurchases)
            {'title': 'Purchase Orders', 'subtitle': 'Supplier purchases & stock receiving', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFF8B5CF6), 'route': '/purchases'},
          if (perms.canAccessSuppliers)
            {'title': 'Suppliers', 'subtitle': 'Supplier profiles, payables & terms', 'icon': Icons.local_shipping_outlined, 'color': AppColors.primary, 'route': '/suppliers'},
        ],
      });
    }

    // Finance & Analytics
    if (perms.canAccessExpenses || perms.canAccessReports) {
      sections.add({
        'title': 'FINANCE & ANALYTICS',
        'items': [
          if (perms.canAccessExpenses)
            {'title': 'Expenses', 'subtitle': 'Rent, utilities, salaries & shop expenses', 'icon': Icons.payments_outlined, 'color': const Color(0xFFF59E0B), 'route': '/expenses'},
          if (perms.canAccessReports)
            {'title': 'Reports & Analytics', 'subtitle': 'Profit & loss, sales, inventory reports', 'icon': Icons.bar_chart_rounded, 'color': const Color(0xFF3B82F6), 'route': '/reports'},
        ],
      });
    }

    // Admin & System
    if (perms.canAccessUsers || perms.canAccessSettings) {
      sections.add({
        'title': 'ADMIN & SYSTEM',
        'items': [
          if (perms.canAccessUsers)
            {'title': 'User Management', 'subtitle': 'Staff accounts, roles & permissions', 'icon': Icons.admin_panel_settings_outlined, 'color': AppColors.error, 'route': '/users'},
          if (perms.canAccessSettings)
            {'title': 'Shop Settings', 'subtitle': 'Receipt logo, taxes & shop information', 'icon': Icons.storefront_outlined, 'color': AppColors.primary, 'route': '/settings'},
          if (perms.canDeleteRecords)
            {'title': 'Audit Logs', 'subtitle': 'Track all sensitive system actions', 'icon': Icons.history_outlined, 'color': AppColors.textSecondary, 'route': '/audit-logs'},
        ],
      });
    }

    return sections;
  }
}
