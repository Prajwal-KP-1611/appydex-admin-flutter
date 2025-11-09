import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/auth/auth_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../repositories/admin_exceptions.dart';
import '../../repositories/end_users_repo.dart';
import '../../routes.dart';
import '../../widgets/delete_user_dialog.dart';
import '../../widgets/status_chip.dart';
import 'user_detail_screen.dart';

/// End-users (customers) management screen
class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final _searchController = TextEditingController();
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasView = can(ref, Permissions.usersView);

    if (!hasView) {
      return AdminScaffold(
        currentRoute: AppRoute.users,
        title: 'Users',
        child: Center(
          child: Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'You do not have permission to view users.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AdminScaffold(
      currentRoute: AppRoute.users,
      title: 'Users (End-users)',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search by email, phone, or name',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _loadUsers(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: _statusFilter,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('All')),
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'suspended',
                                child: Text('Suspended'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _statusFilter = value);
                              _loadUsers();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Users list (connected to repository)
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final usersState = ref.watch(endUsersProvider);

                  return usersState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) {
                      // Check if this is the missing endpoint error
                      final isEndpointMissing = err is AdminEndpointMissing;

                      if (isEndpointMissing) {
                        return Container(
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            border: Border.all(
                              color: const Color(0xFFD32F2F),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Color(0xFFD32F2F),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Backend Endpoint Missing',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'The backend has not implemented the users list endpoint yet.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Missing: GET /api/v1/admin/users',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'See docs/backend-tickets/BACKEND_TICKET_USERS_LIST.md for details.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => ref
                                          .read(endUsersProvider.notifier)
                                          .loadUsers(),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFD32F2F,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => ref
                                          .read(endUsersProvider.notifier)
                                          .enableMockData(),
                                      icon: const Icon(Icons.science),
                                      label: const Text(
                                        'Use Mock Data (79 users)',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFD32F2F,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFD32F2F),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Other errors
                      final message = err is Exception
                          ? err.toString()
                          : 'Failed to load users';

                      // Check if it's an authentication error
                      final isAuthError =
                          message.toLowerCase().contains('authentication') ||
                          message.toLowerCase().contains('authorization');

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAuthError
                                  ? Icons.lock_outline
                                  : Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            if (isAuthError) ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Log out and redirect to login
                                  ref
                                      .read(adminSessionProvider.notifier)
                                      .logout();
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Log Out & Re-login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                onPressed: () => ref
                                    .read(endUsersProvider.notifier)
                                    .loadUsers(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    data: (pagination) {
                      final items = pagination.items;
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try changing your search or refresh',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Card(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 24,
                                  headingRowColor: WidgetStateProperty.all(
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Trust Score')),
                                    DataColumn(label: Text('Bookings')),
                                    DataColumn(label: Text('Total Spent')),
                                    DataColumn(label: Text('Disputes')),
                                    DataColumn(label: Text('Last Active')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: items.map((user) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      UserDetailScreen(
                                                        userId: user.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              user.email,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            user.name ?? '—',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DataCell(
                                          _buildStatusChip(
                                            user.accountStatus ?? 'active',
                                          ),
                                        ),
                                        DataCell(
                                          _buildTrustScoreChip(user.trustScore),
                                        ),
                                        DataCell(
                                          Text(
                                            '${user.totalBookings ?? user.bookingCount ?? 0}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatCurrency(user.totalSpent),
                                          ),
                                        ),
                                        DataCell(
                                          _buildDisputesBadge(
                                            user.openDisputes ?? 0,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _formatDateTime(
                                              user.lastActivityAt,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(_formatDateTime(user.createdAt)),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PopupMenuButton<String>(
                                                tooltip: 'Actions',
                                                onSelected: (value) =>
                                                    _handleAction(
                                                      context,
                                                      ref,
                                                      value,
                                                      user,
                                                    ),
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'view',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.visibility,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('View Details'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuDivider(),
                                                  if (!user.isSuspended)
                                                    const PopupMenuItem(
                                                      value: 'suspend',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .pause_circle_outline,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('Suspend'),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    const PopupMenuItem(
                                                      value: 'unsuspend',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .play_circle_outline,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('Unsuspend'),
                                                        ],
                                                      ),
                                                    ),
                                                  const PopupMenuDivider(),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete_outline,
                                                          size: 18,
                                                          color: Colors.red,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'Delete User',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          // Pagination controls
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: pagination.page > 1
                                      ? () => ref
                                            .read(endUsersProvider.notifier)
                                            .previousPage()
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Page ${pagination.page} • ${pagination.total} total',
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed:
                                      pagination.page < pagination.totalPages
                                      ? () => ref
                                            .read(endUsersProvider.notifier)
                                            .nextPage()
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadUsers() {
    final search = _searchController.text.trim();
    ref
        .read(endUsersProvider.notifier)
        .loadUsers(
          page: 1,
          search: search.isEmpty ? null : search,
          status: _statusFilter,
        );
  }

  Future<void> _confirmSuspend(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Suspend user'),
        content: const Text(
          'Are you sure you want to suspend this user account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(endUsersProvider.notifier).suspendUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User suspended')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to suspend user: $e')));
    }
  }

  Future<void> _confirmUnsuspend(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Unsuspend user'),
        content: const Text('Do you want to restore this user account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Unsuspend'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(endUsersProvider.notifier).unsuspendUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User unsuspended')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unsuspend user: $e')));
    }
  }

  // Helper methods for displaying data
  Widget _buildStatusChip(String status) {
    Color color;
    IconData? icon;
    
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'suspended':
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case 'inactive':
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.blue;
        icon = null;
    }

    return StatusChip(
      label: status.toUpperCase(),
      color: color,
      icon: icon,
      compact: true,
    );
  }

  Widget _buildTrustScoreChip(int? score) {
    if (score == null) {
      return const Text('—', style: TextStyle(color: Colors.grey));
    }

    Color color;
    IconData icon;
    if (score >= 80) {
      color = Colors.green;
      icon = Icons.verified;
    } else if (score >= 50) {
      color = Colors.orange;
      icon = Icons.warning_amber;
    } else {
      color = Colors.red;
      icon = Icons.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$score',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildDisputesBadge(int count) {
    if (count == 0) {
      return const Text('0', style: TextStyle(color: Colors.grey));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red.shade700,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatCurrency(int? amountInPaise) {
    if (amountInPaise == null) return '—';
    final rupees = amountInPaise / 100;
    return '₹${rupees.toStringAsFixed(2)}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return DateFormat.yMMMd().format(dateTime);
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    EndUser user,
  ) async {
    switch (action) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.id)),
        );
        break;
      case 'suspend':
        await _confirmSuspend(context, ref, user.id);
        break;
      case 'unsuspend':
        await _confirmUnsuspend(context, ref, user.id);
        break;
      case 'delete':
        await _showDeleteDialog(context, ref, user);
        break;
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    EndUser user,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DeleteUserDialog(
        userId: user.id,
        userName: user.name ?? user.email,
        userEmail: user.email,
        createdAt: user.createdAt,
      ),
    );

    if (result == null || !mounted) return;

    final deletionType = result['deletion_type'] as String;
    final reason = result['reason'] as String;

    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call delete API
      final repository = ref.read(endUsersRepositoryProvider);
      final deleteResult = await repository.deleteUser(
        user.id,
        deletionType: deletionType,
        reason: reason,
      );

      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Refresh user list
      await ref.read(endUsersProvider.notifier).loadUsers();

      // Show success message
      if (!mounted) return;
      final softDeleted = deleteResult['soft_deleted'] as bool? ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            softDeleted
                ? 'User suspended successfully (can be restored)'
                : 'User deleted successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
