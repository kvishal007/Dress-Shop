import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/shared/widgets/coming_soon_banner.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audit Logs are coming soon!')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const ComingSoonBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by action or user...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Sales', 'Products', 'Users', 'Settings'].map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(label: Text(f, style: const TextStyle(fontSize: 11)), selected: f == 'All', onSelected: (_) {}),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.history_outlined,
              title: 'No Audit Logs Yet',
              message: 'All sensitive actions like price changes, sales voids, and user management will be recorded here.',
            ),
          ),
        ],
      ),
    );
  }
}
