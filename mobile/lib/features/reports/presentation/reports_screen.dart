import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/core/utils/formatters.dart';
import 'package:smart_dress_shop_pos/core/utils/role_permissions.dart';
import 'package:smart_dress_shop_pos/features/auth/presentation/providers/auth_provider.dart';
import 'package:smart_dress_shop_pos/features/reports/presentation/providers/report_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _periods = ['today', 'week', 'month', 'year'];
  final _periodDisplay = ['Today', 'This Week', 'This Month', 'This Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final user = ref.watch(authProvider).user;
    final canViewProfit = user != null && RolePermissions(user.role).canViewProfitData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Sales'),
            const Tab(text: 'Inventory'),
            if (canViewProfit) const Tab(text: 'Profit & Loss'),
            if (!canViewProfit) const Tab(icon: Icon(Icons.lock, size: 16), text: 'Profit & Loss'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(reportState.period),
          Expanded(
            child: reportState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSalesTab(reportState.salesData),
                      _buildInventoryTab(reportState.inventoryData),
                      canViewProfit 
                          ? _buildProfitLossTab(reportState.profitLossData)
                          : _buildLockedTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(String currentPeriod) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _periods[i] == currentPeriod;
          return GestureDetector(
            onTap: () => ref.read(reportProvider.notifier).setPeriod(_periods[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_periodDisplay[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfitLossTab(Map<String, dynamic>? data) {
    final revenue = (data?['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final cogs = (data?['totalCogs'] as num?)?.toDouble() ?? 0.0;
    final grossProfit = (data?['grossProfit'] as num?)?.toDouble() ?? 0.0;
    final expenses = (data?['totalExpenses'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (data?['netProfit'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _plCard('Total Revenue', Formatters.formatCurrency(revenue), Icons.attach_money, AppColors.accent),
          _plCard('Cost of Goods Sold', Formatters.formatCurrency(cogs), Icons.price_change_outlined, AppColors.error),
          _plCard('Gross Profit', Formatters.formatCurrency(grossProfit), Icons.trending_up, AppColors.info),
          _plCard('Operating Expenses', Formatters.formatCurrency(expenses), Icons.payments_outlined, const Color(0xFF8B5CF6)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: netProfit >= 0 ? AppColors.primary : AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Profit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(Formatters.formatCurrency(netProfit), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTab(Map<String, dynamic>? data) {
    final sales = (data?['totalSales'] as num?)?.toDouble() ?? 0.0;
    final count = (data?['count'] as num?)?.toInt() ?? 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 48, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(Formatters.formatCurrency(sales), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const Text('Total Sales Volume', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text('$count orders processed', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(Map<String, dynamic>? data) {
    final items = (data?['totalItems'] as num?)?.toInt() ?? 0;
    final costValue = (data?['totalValue'] as num?)?.toDouble() ?? 0.0;
    final retailValue = (data?['retailValue'] as num?)?.toDouble() ?? 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _plCard('Total Items in Stock', '$items', Icons.inventory_2, AppColors.primary),
          _plCard('Total Inventory Cost', Formatters.formatCurrency(costValue), Icons.account_balance_wallet, AppColors.warning),
          _plCard('Estimated Retail Value', Formatters.formatCurrency(retailValue), Icons.store, AppColors.accent),
        ],
      ),
    );
  }

  Widget _plCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('Access Denied', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 6),
          Text('You do not have permission to view profit margins.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
