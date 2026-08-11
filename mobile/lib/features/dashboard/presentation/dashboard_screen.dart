import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/role_permissions.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final perms = RolePermissions(user?.role ?? 'CASHIER');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.checkroom, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            const Text('Smart POS Dashboard'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: perms.roleColor.withOpacity(0.12),
                border: Border.all(color: perms.roleColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(perms.roleIcon, size: 12, color: perms.roleColor),
                  const SizedBox(width: 4),
                  Text(
                    perms.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: perms.roleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user?.name ?? 'User', perms),
            const SizedBox(height: 20),
            _buildRoleSummarySection(perms),
            const SizedBox(height: 20),
            _buildMetricsSection(perms),
            const SizedBox(height: 24),
            _buildQuickActionsSection(perms, context),
            if (perms.canViewProfitData) ...[
              const SizedBox(height: 24),
              _buildFinancialSection(perms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String name, RolePermissions perms) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: perms.roleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(perms.roleIcon, color: perms.roleColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name! 👋',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  perms.getRoleWelcomeMessage(),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSummarySection(RolePermissions perms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: perms.roleColor.withOpacity(0.05),
        border: Border.all(color: perms.roleColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: perms.roleColor, size: 18),
              const SizedBox(width: 8),
              Text(
                '${perms.displayName} Access Level',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: perms.roleColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: perms.getAccessList().map((access) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.accent, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      access,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(RolePermissions perms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Business Summary",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 13),
              label: const Text('Today', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: _buildMetricCards(perms),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildMetricCards(RolePermissions perms) {
    final cards = <Widget>[
      StatCard(
        title: "Today's Sales",
        value: Formatters.formatCurrency(0.00),
        subtitle: '0 Orders completed',
        icon: Icons.point_of_sale,
        iconColor: AppColors.accentDark,
        iconBackgroundColor: AppColors.accent.withOpacity(0.1),
      ),
    ];

    if (perms.canViewProfitData) {
      cards.add(StatCard(
        title: 'Gross Profit',
        value: Formatters.formatCurrency(0.00),
        subtitle: 'Margin: 0.0%',
        icon: Icons.trending_up,
        iconColor: AppColors.info,
        iconBackgroundColor: AppColors.info.withOpacity(0.1),
      ));
    }

    if (perms.canAccessCustomers) {
      cards.add(StatCard(
        title: 'Pending Credit',
        value: Formatters.formatCurrency(0.00),
        subtitle: '0 Accounts pending',
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppColors.warning,
        iconBackgroundColor: AppColors.warning.withOpacity(0.1),
      ));
    }

    if (perms.canAccessInventory) {
      cards.add(StatCard(
        title: 'Low Stock Items',
        value: '0 Items',
        subtitle: 'Needs replenishment',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.error,
        iconBackgroundColor: AppColors.error.withOpacity(0.1),
      ));
    }

    if (perms.canAccessExpenses) {
      cards.add(StatCard(
        title: "Today's Expenses",
        value: Formatters.formatCurrency(0.00),
        subtitle: '0 Expense entries',
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFF8B5CF6),
        iconBackgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
      ));
    }

    if (perms.canViewProfitData) {
      cards.add(StatCard(
        title: 'Net Profit Today',
        value: Formatters.formatCurrency(0.00),
        subtitle: 'After expenses',
        icon: Icons.account_balance_outlined,
        iconColor: AppColors.accentDark,
        iconBackgroundColor: AppColors.accent.withOpacity(0.1),
      ));
    }

    return cards;
  }

  Widget _buildQuickActionsSection(RolePermissions perms, BuildContext context) {
    final actions = perms.getQuickActions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Action Shortcuts',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate((actions.length / 2).ceil(), (rowIdx) {
          final a = rowIdx * 2;
          final b = a + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: _actionButton(actions[a], context)),
                if (b < actions.length) ...[
                  const SizedBox(width: 10),
                  Expanded(child: _actionButton(actions[b], context)),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _actionButton(Map<String, dynamic> action, BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        final route = action['route'] as String?;
        if (route != null) context.push(route);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: action['color'] as Color),
      ),
      icon: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 18),
      label: Text(
        action['label'] as String,
        style: TextStyle(
          color: action['color'] as Color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFinancialSection(RolePermissions perms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _finRow('Total Revenue', Formatters.formatCurrency(0), AppColors.textPrimary),
              const Divider(height: 20),
              _finRow('Cost of Goods Sold', '- ${Formatters.formatCurrency(0)}', AppColors.error),
              _finRow('Gross Profit', Formatters.formatCurrency(0), AppColors.accent),
              const Divider(height: 20),
              _finRow('Operating Expenses', '- ${Formatters.formatCurrency(0)}', AppColors.warning),
              const Divider(height: 20),
              _finRow('Net Profit', Formatters.formatCurrency(0), AppColors.accentDark, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _finRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

extension RolePermissionsExt on RolePermissions {
  String getRoleWelcomeMessage() {
    switch (role) {
      case 'ADMIN':
        return 'Full system access • All modules & reports available';
      case 'MANAGER':
        return 'Store management access • Products, inventory & reports';
      case 'CASHIER':
        return 'POS terminal ready • Start billing customers';
      case 'STOCK_STAFF':
        return 'Inventory management access • Stock movements & purchases';
      case 'VIEWER':
        return 'Read-only access • View reports and analytics';
      default:
        return 'Smart Dress Shop POS Terminal Ready';
    }
  }

  List<String> getAccessList() {
    switch (role) {
      case 'ADMIN':
        return ['POS Billing', 'Products & Variants', 'Inventory', 'Purchases', 'Sales', 'Customers', 'Suppliers', 'Expenses', 'Reports', 'Users', 'Settings', 'Audit Logs'];
      case 'MANAGER':
        return ['POS Billing', 'Products & Variants', 'Inventory', 'Purchases', 'Sales', 'Customers', 'Suppliers', 'Expenses', 'Reports'];
      case 'CASHIER':
        return ['POS Billing', 'Sales History', 'Customer Lookup', 'Receipts'];
      case 'STOCK_STAFF':
        return ['Inventory', 'Purchases', 'Stock Adjustments', 'Product View'];
      case 'VIEWER':
        return ['Sales Reports', 'Expense Reports', 'Inventory Reports'];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> getQuickActions() {
    switch (role) {
      case 'ADMIN':
        return [
          {'label': 'New POS Billing', 'icon': Icons.add_shopping_cart, 'color': AppColors.accentDark, 'route': '/pos'},
          {'label': 'Add Product', 'icon': Icons.add_box_outlined, 'color': AppColors.primary, 'route': '/products'},
          {'label': 'New Purchase Order', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFF3B82F6), 'route': '/purchases'},
          {'label': 'Add Expense', 'icon': Icons.payments_outlined, 'color': const Color(0xFF8B5CF6), 'route': '/expenses'},
          {'label': 'View Reports', 'icon': Icons.bar_chart, 'color': AppColors.warning, 'route': '/reports'},
          {'label': 'Manage Users', 'icon': Icons.manage_accounts, 'color': AppColors.error, 'route': '/users'},
        ];
      case 'MANAGER':
        return [
          {'label': 'New POS Billing', 'icon': Icons.add_shopping_cart, 'color': AppColors.accentDark, 'route': '/pos'},
          {'label': 'Add Product', 'icon': Icons.add_box_outlined, 'color': AppColors.primary, 'route': '/products'},
          {'label': 'New Purchase Order', 'icon': Icons.shopping_bag_outlined, 'color': const Color(0xFF3B82F6), 'route': '/purchases'},
          {'label': 'Add Expense', 'icon': Icons.payments_outlined, 'color': const Color(0xFF8B5CF6), 'route': '/expenses'},
          {'label': 'View Sales Report', 'icon': Icons.receipt_long, 'color': AppColors.warning, 'route': '/reports'},
          {'label': 'Process Return', 'icon': Icons.assignment_return_outlined, 'color': AppColors.error, 'route': '/returns'},
        ];
      case 'CASHIER':
        return [
          {'label': 'New POS Billing', 'icon': Icons.add_shopping_cart, 'color': AppColors.accentDark, 'route': '/pos'},
          {'label': "Today's Sales", 'icon': Icons.receipt_long, 'color': AppColors.primary, 'route': '/sales'},
          {'label': 'Customer Lookup', 'icon': Icons.person_search, 'color': const Color(0xFF3B82F6), 'route': '/customers'},
        ];
      case 'STOCK_STAFF':
        return [
          {'label': 'New Purchase', 'icon': Icons.shopping_bag_outlined, 'color': AppColors.accentDark, 'route': '/purchases'},
          {'label': 'Stock Adjustment', 'icon': Icons.tune, 'color': AppColors.primary, 'route': '/inventory'},
          {'label': 'View Inventory', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFF3B82F6), 'route': '/inventory'},
        ];
      default:
        return [
          {'label': 'View Reports', 'icon': Icons.bar_chart, 'color': AppColors.primary, 'route': '/reports'},
        ];
    }
  }
}
