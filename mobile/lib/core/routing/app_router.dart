import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/splash_screen.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/login_screen.dart';
import 'package:smart_dress_shop_pos/features/dashboard/presentation/dashboard_screen.dart';
import 'package:smart_dress_shop_pos/features/pos/presentation/pos_screen.dart';
import 'package:smart_dress_shop_pos/features/inventory/presentation/inventory_screen.dart';
import 'package:smart_dress_shop_pos/features/sales/presentation/sales_screen.dart';
import 'package:smart_dress_shop_pos/features/more/presentation/more_screen.dart';
import 'package:smart_dress_shop_pos/features/customers/presentation/customers_screen.dart';
import 'package:smart_dress_shop_pos/features/suppliers/presentation/suppliers_screen.dart';
import 'package:smart_dress_shop_pos/features/purchases/presentation/purchases_screen.dart';
import 'package:smart_dress_shop_pos/features/expenses/presentation/expenses_screen.dart';
import 'package:smart_dress_shop_pos/features/reports/presentation/reports_screen.dart';
import 'package:smart_dress_shop_pos/features/returns/presentation/returns_screen.dart';
import 'package:smart_dress_shop_pos/features/products/presentation/products_screen.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/users_screen.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/shop_settings_screen.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/audit_logs_screen.dart';
import 'package:smart_dress_shop_pos/shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.loading || authState.status == AuthStatus.initial) {
        return isSplash ? null : '/splash';
      }

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && (isLoggingIn || isSplash)) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // ─── Shell with bottom nav ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          // 0 – Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          // 1 – POS
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/pos',
              builder: (_, __) => const PosScreen(),
            ),
          ]),
          // 2 – Inventory
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/inventory',
              builder: (_, __) => const InventoryScreen(),
            ),
          ]),
          // 3 – Sales
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/sales',
              builder: (_, __) => const SalesScreen(),
            ),
          ]),
          // 4 – More
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/more',
              builder: (_, __) => const MoreScreen(),
            ),
          ]),
        ],
      ),

      // ─── Module Routes (pushed on top of shell) ────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/customers',
        builder: (_, __) => const CustomersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/suppliers',
        builder: (_, __) => const SuppliersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/purchases',
        builder: (_, __) => const PurchasesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/expenses',
        builder: (_, __) => const ExpensesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/returns',
        builder: (_, __) => const ReturnsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/products',
        builder: (_, __) => const ProductsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/users',
        builder: (_, __) => const UsersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (_, __) => const ShopSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/audit-logs',
        builder: (_, __) => const AuditLogsScreen(),
      ),
    ],
  );
});

class AuthStateListenable extends ChangeNotifier {
  AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
