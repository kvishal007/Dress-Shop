import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returns & Exchanges')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _typeCard('Returns', '0', Icons.undo, AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeCard('Exchanges', '0', Icons.swap_horiz, AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeCard('Refunds', '₹0', Icons.currency_rupee, AppColors.info),
                ),
              ],
            ),
          ),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.assignment_return_outlined,
              title: 'No Returns Processed',
              message: 'To process a return, find the original invoice in Sales History and select Return/Exchange.',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.warning,
        onPressed: () {},
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text('Find Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _typeCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
