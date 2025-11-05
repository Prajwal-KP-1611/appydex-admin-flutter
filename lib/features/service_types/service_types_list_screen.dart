import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/service_type.dart';
import '../../repositories/service_type_repo.dart';
import '../../routes.dart';
import 'service_type_form_dialog.dart';

/// Service Types management screen
/// Displays all service types (master catalog) with CRUD operations
class ServiceTypesListScreen extends ConsumerStatefulWidget {
  const ServiceTypesListScreen({super.key});

  @override
  ConsumerState<ServiceTypesListScreen> createState() =>
      _ServiceTypesListScreenState();
}

class _ServiceTypesListScreenState
    extends ConsumerState<ServiceTypesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypesAsync = ref.watch(serviceTypesProvider);

    return AdminScaffold(
      currentRoute: AppRoute.services,
      title: 'Service Types',
      actions: [
        FilledButton.icon(
          onPressed: () => _showServiceTypeDialog(context, ref, null),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Create Service Type'),
        ),
        const SizedBox(width: 16),
      ],
      child: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search service types...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(serviceTypesProvider.notifier)
                                    .clearFilters();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref
                          .read(serviceTypesProvider.notifier)
                          .search(value.isEmpty ? null : value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(serviceTypesProvider.notifier).clearFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear Filters'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: serviceTypesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load service types: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(serviceTypesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (pagination) {
                final serviceTypes = pagination.items;

                if (serviceTypes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No service types found'
                              : 'No service types yet',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_searchController.text.isEmpty)
                          FilledButton.icon(
                            onPressed: () =>
                                _showServiceTypeDialog(context, ref, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Service Type'),
                          ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats cards
                      Row(
                        children: [
                          _StatCard(
                            title: 'Total Types',
                            value: pagination.total.toString(),
                            icon: Icons.category,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Total Services',
                            value: serviceTypes
                                .fold<int>(
                                  0,
                                  (sum, t) => sum + (t.servicesCount ?? 0),
                                )
                                .toString(),
                            icon: Icons.inventory_2,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Average Services',
                            value: serviceTypes.isEmpty
                                ? '0'
                                : (serviceTypes.fold<int>(
                                            0,
                                            (sum, t) =>
                                                sum + (t.servicesCount ?? 0),
                                          ) /
                                          serviceTypes.length)
                                      .toStringAsFixed(1),
                            icon: Icons.analytics,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Service types table
                      Card(
                        child: Column(
                          children: [
                            // Table header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Service Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Services',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Created',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      'Actions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table rows
                            ...serviceTypes.map(
                              (serviceType) => _ServiceTypeRow(
                                serviceType: serviceType,
                                onEdit: () => _showServiceTypeDialog(
                                  context,
                                  ref,
                                  serviceType,
                                ),
                                onDelete: () => _deleteServiceType(
                                  context,
                                  ref,
                                  serviceType,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pagination info
                      if (pagination.total > pagination.items.length)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Showing ${pagination.items.length} of ${pagination.total} service types',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceTypeDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceType? serviceType,
  ) {
    showDialog(
      context: context,
      builder: (context) => ServiceTypeFormDialog(serviceType: serviceType),
    );
  }

  Future<void> _deleteServiceType(
    BuildContext context,
    WidgetRef ref,
    ServiceType serviceType,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${serviceType.name}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.dangerRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will CASCADE delete all ${serviceType.servicesCount ?? 0} related services!',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(serviceTypesProvider.notifier).delete(serviceType.id);
        if (context.mounted) {
          ToastService.showSuccess(
            context,
            'Service type "${serviceType.name}" deleted successfully',
          );
        }
      } catch (error) {
        if (context.mounted) {
          ToastService.showError(
            context,
            'Failed to delete service type: $error',
          );
        }
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTypeRow extends StatelessWidget {
  const _ServiceTypeRow({
    required this.serviceType,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceType serviceType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              serviceType.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              serviceType.description ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: serviceType.description != null
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              serviceType.servicesCount?.toString() ?? '0',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              serviceType.createdAt != null
                  ? _formatDate(serviceType.createdAt!)
                  : '—',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Edit Service Type',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 20, color: AppTheme.dangerRed),
                  tooltip: 'Delete Service Type',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
