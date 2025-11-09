import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/permissions.dart';
import '../../core/auth/auth_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../repositories/admin_exceptions.dart';
import '../../repositories/end_users_repo.dart';
import '../../routes.dart';
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
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final user = items[idx];
                                final created = user.createdAt != null
                                    ? DateFormat.yMMMd().add_Hm().format(
                                        user.createdAt!,
                                      )
                                    : '—';

                                return ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserDetailScreen(userId: user.id),
                                      ),
                                    );
                                  },
                                  title: Text(user.email),
                                  subtitle: Text(
                                    '${user.name ?? ''} • Created: $created • Bookings: ${user.bookingCount ?? 0}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!user.isSuspended)
                                        TextButton(
                                          onPressed: () => _confirmSuspend(
                                            context,
                                            ref,
                                            user.id,
                                          ),
                                          child: const Text('Suspend'),
                                        )
                                      else
                                        TextButton(
                                          onPressed: () => _confirmUnsuspend(
                                            context,
                                            ref,
                                            user.id,
                                          ),
                                          child: const Text('Unsuspend'),
                                        ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: 'Anonymize user',
                                        onPressed: () => _confirmAnonymize(
                                          context,
                                          ref,
                                          user.id,
                                        ),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  Future<void> _confirmAnonymize(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Anonymize user'),
        content: const Text(
          'Anonymizing will remove personal data for this user. This action cannot be undone. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Anonymize'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(endUsersProvider.notifier).anonymizeUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User anonymized')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to anonymize user: $e')));
    }
  }
}
