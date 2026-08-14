import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';
import 'package:smart_dress_shop_pos/shared/widgets/empty_state_widget.dart';
import 'package:smart_dress_shop_pos/features/settings/presentation/providers/audit_provider.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});
  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final _filters = ['All', 'SALE', 'PRODUCT', 'USER', 'SETTINGS'];

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditProvider);

    final filteredLogs = auditState.logs.where((log) {
      final matchesSearch = log.action.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            log.details.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            (log.userId['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesFilter = _selectedFilter == 'All' || log.entity == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(auditProvider.notifier).loadLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search by action or user...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f, style: TextStyle(fontSize: 11, color: _selectedFilter == f ? Colors.white : AppColors.textPrimary)),
                      selected: _selectedFilter == f,
                      selectedColor: AppColors.primary,
                      onSelected: (_) => setState(() => _selectedFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: auditState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLogs.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.history_outlined,
                        title: 'No Audit Logs Found',
                        message: 'No actions matching your filters were found.',
                      )
                    : ListView.separated(
                        itemCount: filteredLogs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          IconData icon;
                          Color color;
                          
                          switch(log.entity) {
                            case 'SALE': icon = Icons.receipt; color = AppColors.accent; break;
                            case 'PRODUCT': icon = Icons.checkroom; color = AppColors.info; break;
                            case 'USER': icon = Icons.person; color = AppColors.warning; break;
                            case 'SETTINGS': icon = Icons.settings; color = AppColors.textSecondary; break;
                            default: icon = Icons.info; color = AppColors.primary; break;
                          }

                          if (log.action.contains('VOID') || log.action.contains('DELETE') || log.action.contains('DEACTIVATE')) {
                            color = AppColors.error;
                          }

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(log.details, style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text('By: ${log.userId['name']} (${log.userId['role']}) • ${DateFormat('MMM dd, yyyy HH:mm').format(log.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
