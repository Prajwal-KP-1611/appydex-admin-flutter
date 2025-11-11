import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/service_type.dart';
import '../../repositories/service_type_repo.dart';
import '../../routes.dart';
import '../../widgets/cors_diagnostics_banner.dart';
import '../shared/admin_sidebar.dart';

/// Services (Service Categories) Management Screen
/// Allows admins to CREATE/READ/UPDATE/DELETE service categories like:
/// - Plumbing
/// - Electrical
/// - Delivery
/// - Internet/Broadband
/// etc.
class ServicesListScreen extends ConsumerStatefulWidget {
  const ServicesListScreen({super.key});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // CORS diagnostics state
  String? _corsFailureMethod;
  String? _corsFailureUrl;
  Map<String, dynamic>? _corsFailureHeaders;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceType> _filterServiceTypes(List<ServiceType> serviceTypes) {
    if (_searchQuery.isEmpty) return serviceTypes;

    return serviceTypes.where((type) {
      return type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (type.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  void _showCreateDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Service Category'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name *',
                    hintText: 'e.g., Plumbing, Electrical, Delivery',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of this service category',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final repo = ref.read(serviceTypeRepositoryProvider);
                await repo.create(
                  ServiceTypeRequest(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service category created successfully'),
                    ),
                  );
                  ref.invalidate(serviceTypesProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(ServiceType serviceType) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: serviceType.name);
    final descController = TextEditingController(
      text: serviceType.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Service Category'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final repo = ref.read(serviceTypeRepositoryProvider);
                await repo.update(
                  serviceType.id,
                  ServiceTypeRequest(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service category updated successfully'),
                    ),
                  );
                  ref.invalidate(serviceTypesProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ServiceType serviceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Category'),
        content: Text(
          'Are you sure you want to delete "${serviceType.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () async {
              try {
                final repo = ref.read(serviceTypeRepositoryProvider);
                await repo.delete(serviceType.id);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service category deleted successfully'),
                    ),
                  );
                  ref.invalidate(serviceTypesProvider);
                }
              } catch (e) {
                // Check if this is a CORS failure on web (DioException with null status)
                if (kIsWeb && e is DioException) {
                  final statusCode = e.response?.statusCode;
                  if (statusCode == null &&
                      e.type == DioExceptionType.unknown) {
                    // Capture CORS failure details
                    setState(() {
                      _corsFailureMethod = e.requestOptions.method;
                      _corsFailureUrl = e.requestOptions.uri.toString();
                      _corsFailureHeaders = Map<String, dynamic>.from(
                        e.requestOptions.headers,
                      );
                    });
                  }
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceTypesAsync = ref.watch(serviceTypesProvider);

    return AdminScaffold(
      currentRoute: AppRoute.services,
      title: 'Service Categories',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Categories',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage service categories like Plumbing, Electrical, Delivery, etc.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Category'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Show CORS diagnostics banner if DELETE failed on web
            if (_corsFailureMethod != null &&
                _corsFailureUrl != null &&
                _corsFailureHeaders != null)
              CORSDiagnosticsBanner(
                method: _corsFailureMethod!,
                url: _corsFailureUrl!,
                headers: _corsFailureHeaders!,
              ),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Service categories are the high-level types of services vendors can offer. '
                        'Vendors can also request new categories via "Service Type Requests".',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search categories',
                    hintText: 'Enter category name...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: serviceTypesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
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
                  final filtered = _filterServiceTypes(pagination.items);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No service categories yet',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first service category to get started',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _showCreateDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Category'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                        headingTextStyle: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'SL No.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Category',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Description',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Created',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: filtered.asMap().entries.map((entry) {
                          final index = entry.key;
                          final type = entry.value;
                          // Calculate serial number based on current page
                          final serialNumber =
                              (pagination.page - 1) * pagination.pageSize +
                              index +
                              1;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '$serialNumber',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    type.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 400,
                                  child: Text(
                                    type.description ?? 'No description',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat(
                                    'MMM d, y',
                                  ).format(type.createdAt ?? DateTime.now()),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      tooltip: 'Edit',
                                      onPressed: () => _showEditDialog(type),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: AppTheme.dangerRed,
                                      tooltip: 'Delete',
                                      onPressed: () => _showDeleteDialog(type),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
