import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _period = 'Today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profit & Loss'),
            Tab(text: 'Sales'),
            Tab(text: 'Inventory'),
            Tab(text: 'Customers'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfitLossTab(),
                _buildSalesTab(),
                _buildInventoryTab(),
                _buildCustomersTab(),
                _buildExpensesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Today', 'Yesterday', 'This Week', 'This Month', 'This Year'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = periods[i] == _period;
          return GestureDetector(
            onTap: () => setState(() => _period = periods[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(periods[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfitLossTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _plCard('Total Revenue', Formatters.formatCurrency(0), Icons.attach_money, AppColors.accent, '+0 orders'),
          _plCard('Cost of Goods Sold', Formatters.formatCurrency(0), Icons.price_change_outlined, AppColors.error, '0 items sold'),
          _plCard('Gross Profit', Formatters.formatCurrency(0), Icons.trending_up, AppColors.info, '0.0% margin'),
          _plCard('Operating Expenses', Formatters.formatCurrency(0), Icons.payments_outlined, const Color(0xFF8B5CF6), '0 expense entries'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Profit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(Formatters.formatCurrency(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plCard(String label, String value, IconData icon, Color color, String sub) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() => _emptyTab(Icons.receipt_long, 'No Sales Data', 'Sales data for $_period will appear here.');
  Widget _buildInventoryTab() => _emptyTab(Icons.inventory_2_outlined, 'No Inventory Data', 'Stock valuation and movement data will appear here.');
  Widget _buildCustomersTab() => _emptyTab(Icons.people_outline, 'No Customer Data', 'Top customers and purchase analytics will appear here.');
  Widget _buildExpensesTab() => _emptyTab(Icons.payments_outlined, 'No Expense Data', 'Expense breakdown by category will appear here.');

  Widget _emptyTab(IconData icon, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
