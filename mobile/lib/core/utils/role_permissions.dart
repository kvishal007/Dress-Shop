import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defines which features each role can access
class RolePermissions {
  final String role;

  const RolePermissions(this.role);

  // Navigation access
  bool get canAccessPos => ['ADMIN', 'MANAGER', 'CASHIER'].contains(role);
  bool get canAccessInventory => ['ADMIN', 'MANAGER', 'STOCK_STAFF'].contains(role);
  bool get canAccessSales => ['ADMIN', 'MANAGER', 'CASHIER'].contains(role);
  bool get canAccessReports => ['ADMIN', 'MANAGER', 'VIEWER'].contains(role);
  bool get canAccessCustomers => ['ADMIN', 'MANAGER', 'CASHIER'].contains(role);
  bool get canAccessSuppliers => ['ADMIN', 'MANAGER'].contains(role);
  bool get canAccessPurchases => ['ADMIN', 'MANAGER', 'STOCK_STAFF'].contains(role);
  bool get canAccessExpenses => ['ADMIN', 'MANAGER'].contains(role);
  bool get canAccessUsers => ['ADMIN'].contains(role);
  bool get canAccessSettings => ['ADMIN'].contains(role);

  // Feature permissions
  bool get canAddProducts => ['ADMIN', 'MANAGER'].contains(role);
  bool get canEditPrices => ['ADMIN'].contains(role);
  bool get canDeleteRecords => ['ADMIN'].contains(role);
  bool get canViewPurchasePrices => ['ADMIN', 'MANAGER'].contains(role);
  bool get canViewProfitData => ['ADMIN', 'MANAGER'].contains(role);
  bool get canApplyDiscount => ['ADMIN', 'MANAGER', 'CASHIER'].contains(role);
  bool get canVoidSales => ['ADMIN'].contains(role);
  bool get canProcessReturns => ['ADMIN', 'MANAGER'].contains(role);

  // Role display info
  String get displayName {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'MANAGER':
        return 'Store Manager';
      case 'CASHIER':
        return 'Cashier';
      case 'STOCK_STAFF':
        return 'Stock Staff';
      case 'VIEWER':
        return 'Report Viewer';
      default:
        return role;
    }
  }

  Color get roleColor {
    switch (role) {
      case 'ADMIN':
        return const Color(0xFFF59E0B); // Gold
      case 'MANAGER':
        return const Color(0xFF3B82F6); // Blue
      case 'CASHIER':
        return const Color(0xFF10B981); // Green
      case 'STOCK_STAFF':
        return const Color(0xFF8B5CF6); // Purple
      case 'VIEWER':
        return const Color(0xFF64748B); // Gray
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData get roleIcon {
    switch (role) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'MANAGER':
        return Icons.manage_accounts;
      case 'CASHIER':
        return Icons.point_of_sale;
      case 'STOCK_STAFF':
        return Icons.inventory_2;
      case 'VIEWER':
        return Icons.bar_chart;
      default:
        return Icons.person;
    }
  }
}

final rolePermissionsProvider = Provider<RolePermissions>((ref) {
  // This is overridden in the widget tree after login
  return const RolePermissions('CASHIER');
});
