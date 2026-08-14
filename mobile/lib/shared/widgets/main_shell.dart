import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/constants/app_strings.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final perms = RolePermissions(authState.user?.role ?? 'CASHIER');
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Build nav items based on role
    final navItems = _buildNavItems(perms);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.primary,
              selectedIconTheme: const IconThemeData(color: AppColors.accent),
              unselectedIconTheme: const IconThemeData(color: Colors.white60),
              selectedLabelTextStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70, fontSize: 11),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    const Icon(Icons.checkroom, color: AppColors.accent, size: 32),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: perms.roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        perms.role,
                        style: TextStyle(
                          color: perms.roleColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              destinations: navItems.map((item) => NavigationRailDestination(
                icon: Icon(item['icon'] as IconData),
                selectedIcon: Icon(item['selectedIcon'] as IconData),
                label: Text(item['label'] as String),
              )).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        destinations: navItems.map((item) => NavigationDestination(
          icon: Icon(item['icon'] as IconData),
          selectedIcon: Icon(item['selectedIcon'] as IconData, color: AppColors.primary),
          label: item['label'] as String,
        )).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _buildNavItems(RolePermissions perms) {
    final items = <Map<String, dynamic>>[];

    // Home always visible
    items.add({
      'icon': Icons.dashboard_outlined,
      'selectedIcon': Icons.dashboard,
      'label': AppStrings.navHome,
      'route': '/',
    });

    // POS for Admin, Manager, Cashier
    if (perms.canAccessPos) {
      items.add({
        'icon': Icons.point_of_sale_outlined,
        'selectedIcon': Icons.point_of_sale,
        'label': AppStrings.navPos,
        'route': '/pos',
      });
    }

    // Inventory for Admin, Manager, Stock Staff
    if (perms.canAccessInventory) {
      items.add({
        'icon': Icons.inventory_2_outlined,
        'selectedIcon': Icons.inventory_2,
        'label': AppStrings.navInventory,
        'route': '/inventory',
      });
    }

    // Sales for Admin, Manager, Cashier
    if (perms.canAccessSales) {
      items.add({
        'icon': Icons.receipt_long_outlined,
        'selectedIcon': Icons.receipt_long,
        'label': AppStrings.navSales,
        'route': '/sales',
      });
    }

    // More always visible (shows what they can access)
    items.add({
      'icon': Icons.grid_view_outlined,
      'selectedIcon': Icons.grid_view,
      'label': AppStrings.navMore,
      'route': '/more',
    });

    return items;
  }
}
