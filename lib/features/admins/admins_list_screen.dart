import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../models/admin_role.dart';
import '../../models/admin_user.dart';
import '../../repositories/admin_user_repo.dart';
import '../../routes.dart';
import '../shared/admin_sidebar.dart';
import 'admin_form_dialog.dart';

/// Admin Users Management Screen
/// Displays list of admin users with CRUD operations
/// Only accessible to super_admin role
class AdminsListScreen extends ConsumerStatefulWidget {
  const AdminsListScreen({super.key});

  @override
  ConsumerState<AdminsListScreen> createState() => _AdminsListScreenState();
}

class _AdminsListScreenState extends ConsumerState<AdminsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(adminUsersProvider.notifier).loadUsers();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
    });
    ref.read(adminUsersProvider.notifier).loadUsers();
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AdminFormDialog(),
    );

    if (result == true && mounted) {
      ToastService.showSuccess(context, 'Admin user created successfully');
    }
  }

  Future<void> _showEditDialog(AdminUser admin) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AdminFormDialog(admin: admin),
    );

    if (result == true && mounted) {
      ToastService.showSuccess(context, 'Admin user updated successfully');
    }
  }

  Future<void> _confirmDelete(AdminUser admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin User'),
        content: Text(
          'Are you sure you want to delete ${admin.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminUsersProvider.notifier).deleteUser(admin.id);
        if (mounted) {
          ToastService.showSuccess(context, 'Admin user deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          ToastService.showError(
            context,
            'Failed to delete admin user: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(adminSessionProvider);
    final currentRole = ref.watch(currentAdminRoleProvider);
    final adminUsers = ref.watch(adminUsersProvider);

    // Debug logging
    print(
      '[AdminsListScreen] Session: ${session?.email}, Role: ${currentRole?.displayName}, Roles: ${session?.roles.map((r) => r.displayName).join(", ")}',
    );
    final hasSuperAdminRole =
        session?.roles.contains(AdminRole.superAdmin) == true;
    print(
      '[AdminsListScreen] hasSuperAdminRole (any role): $hasSuperAdminRole',
    );
    print(
      '[AdminsListScreen] Is Super Admin (active role): ${currentRole == AdminRole.superAdmin}',
    );

    // Only super_admin can access this screen
    final isSuper = hasSuperAdminRole || currentRole == AdminRole.superAdmin;
    if (!isSuper) {
      print(
        '[AdminsListScreen] Access DENIED for role: ${currentRole?.displayName}',
      );
      return AdminScaffold(
        currentRoute: AppRoute.admins,
        title: 'Access Denied',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppTheme.dangerRed.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Only Super Admins can manage admin users',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDarkSlate.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    print(
      '[AdminsListScreen] Access GRANTED (super admin privileges detected)',
    );

    return AdminScaffold(
      currentRoute: AppRoute.admins,
      title: 'Admin Users',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Admin'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search by email or name',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Table
            Expanded(
              child: adminUsers.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.textDarkSlate.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No admin users found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.textDarkSlate.withOpacity(
                                    0.7,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showCreateDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Admin'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Card(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppTheme.surfaceVariant,
                          ),
                          columns: const [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Roles')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Created')),
                            DataColumn(label: Text('Last Login')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: users.map((admin) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      if (admin.isSuperAdmin)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.star,
                                            size: 16,
                                            color: AppTheme.warningAmber,
                                          ),
                                        ),
                                      Text(admin.email),
                                    ],
                                  ),
                                ),
                                DataCell(Text(admin.name ?? '-')),
                                DataCell(
                                  Wrap(
                                    spacing: 4,
                                    children: admin.roles
                                        .map(
                                          (role) => Chip(
                                            label: Text(
                                              role.displayName,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                DataCell(_buildStatusChip(admin)),
                                DataCell(
                                  Text(
                                    admin.createdAt != null
                                        ? DateFormat(
                                            'MMM d, y',
                                          ).format(admin.createdAt!)
                                        : '-',
                                  ),
                                ),
                                const DataCell(
                                  Text('-'), // Last Login - not yet tracked
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        tooltip: 'Edit',
                                        onPressed: () => _showEditDialog(admin),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: AppTheme.dangerRed,
                                        ),
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmDelete(admin),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ), // End DataTable
                      ), // End inner SingleChildScrollView
                    ), // End outer SingleChildScrollView
                  ); // End Card
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.dangerRed.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load admin users',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getErrorMessage(error),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDarkSlate.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(adminUsersProvider.notifier).loadUsers(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ), // End adminUsers.when()
            ), // End Expanded
          ], // End of Column children
        ), // End Column
      ), // End Padding
    ); // End AdminScaffold
  }

  Widget _buildStatusChip(AdminUser admin) {
    // Since we don't have isActive and mustChangePassword anymore,
    // we'll use a simple chip based on roles
    return Chip(
      label: Text(
        admin.roles.isEmpty ? 'No Role' : admin.roles.first.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: admin.isSuperAdmin
          ? AppTheme.primaryDeepBlue
          : AppTheme.successGreen,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _getErrorMessage(Object error) {
    // Extract AppHttpException from DioException wrapper
    AppHttpException? httpException;
    if (error is DioException && error.error is AppHttpException) {
      httpException = error.error as AppHttpException;
    } else if (error is AppHttpException) {
      httpException = error;
    }

    if (httpException != null) {
      if (httpException.statusCode == 401) {
        return '⏱️ Session expired. Please login again.';
      } else if (httpException.statusCode == 422) {
        return '⚠️ Invalid request format. Please try again.';
      } else if (httpException.statusCode == 403) {
        return '🚫 You don\'t have permission to view admin users.';
      }
      return httpException.message;
    }

    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('failed host lookup') ||
        errorStr.contains('connection refused')) {
      return '🌐 Network error. Please check your connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
