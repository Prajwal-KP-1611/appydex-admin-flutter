import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../core/theme.dart';
import '../../models/admin_role.dart';
import '../../routes.dart';

/// Main admin layout with sidebar navigation
class AdminLayout extends ConsumerWidget {
  const AdminLayout({super.key, required this.child, this.currentRoute});

  final Widget child;
  final AppRoute? currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(adminSessionProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          _AdminSidebar(currentRoute: currentRoute, session: session),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                _AdminTopBar(session: session),

                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends ConsumerWidget {
  const _AdminSidebar({required this.currentRoute, required this.session});

  final AppRoute? currentRoute;
  final AdminSession? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = session?.activeRole;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          right: BorderSide(color: AppTheme.borderGray.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDeepBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AppyDex',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDeepBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDarkSlate.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: AppRoute.dashboard,
                ),

                const _NavSection(title: 'MANAGEMENT'),

                if (role?.hasPermission('admins', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.shield_outlined,
                    label: 'Admin Users',
                    route: AppRoute.admins,
                  ),

                if (role?.hasPermission('vendors', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.store_outlined,
                    label: 'Vendors',
                    route: AppRoute.vendors,
                  ),

                if (role?.hasPermission('users', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.people_outline,
                    label: 'Users',
                    route: AppRoute.users,
                  ),

                if (role?.hasPermission('services', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.category_outlined,
                    label: 'Service Catalog',
                    route: AppRoute.services,
                  ),

                const _NavSection(title: 'COMMERCE'),

                if (role?.hasPermission('plans', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.card_membership_outlined,
                    label: 'Subscription Plans',
                    route: AppRoute.plans,
                  ),

                if (role?.hasPermission('subscriptions', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.subscriptions_outlined,
                    label: 'Subscriptions',
                    route: AppRoute.subscriptions,
                  ),

                if (role?.hasPermission('payments', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.payment_outlined,
                    label: 'Payments',
                    route: AppRoute.payments,
                  ),

                const _NavSection(title: 'ENGAGEMENT'),

                if (role?.hasPermission('campaigns', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.campaign_outlined,
                    label: 'Campaigns',
                    route: AppRoute.campaigns,
                  ),

                if (role?.hasPermission('reviews', 'read') ?? false)
                  _buildNavItem(
                    context: context,
                    icon: Icons.rate_review_outlined,
                    label: 'Reviews',
                    route: AppRoute.reviews,
                  ),

                const _NavSection(title: 'SYSTEM'),

                _buildNavItem(
                  context: context,
                  icon: Icons.history,
                  label: 'Audit Logs',
                  route: AppRoute.audit,
                ),

                _buildNavItem(
                  context: context,
                  icon: Icons.assessment_outlined,
                  label: 'Reports',
                  route: AppRoute.reports,
                ),

                _buildNavItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'Diagnostics',
                  route: AppRoute.diagnostics,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required AppRoute route,
  }) {
    final isActive = currentRoute == route;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive
            ? AppTheme.primaryDeepBlue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(route.path);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppTheme.primaryDeepBlue
                      : AppTheme.textDarkSlate.withOpacity(0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? AppTheme.primaryDeepBlue
                          : AppTheme.textDarkSlate,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  const _NavSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppTheme.textDarkSlate.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AdminTopBar extends ConsumerWidget {
  const _AdminTopBar({required this.session});

  final AdminSession? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray.withOpacity(0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Search Bar (placeholder)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.borderGray.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
            tooltip: 'Notifications',
          ),

          const SizedBox(width: 8),

          // Role Badge
          if (session != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentEmerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session!.activeRole.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.accentEmerald,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(width: 16),

          // User Profile Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryDeepBlue,
                  child: Text(
                    session?.email?.substring(0, 1).toUpperCase() ?? 'A',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session?.email ?? 'Admin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      session?.activeRole.displayName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textDarkSlate.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),

              // Role switching (if multiple roles)
              if (session != null && session!.roles.length > 1)
                ...session!.roles.map((role) {
                  final isActive = role == session!.activeRole;
                  return PopupMenuItem(
                    value: 'switch_${role.value}',
                    child: Row(
                      children: [
                        Icon(
                          isActive
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: AppTheme.primaryDeepBlue,
                        ),
                        const SizedBox(width: 8),
                        Text('Switch to ${role.displayName}'),
                      ],
                    ),
                  );
                }),

              if (session != null && session!.roles.length > 1)
                const PopupMenuDivider(),

              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(adminSessionProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } else if (value.startsWith('switch_')) {
                final roleValue = value.substring(7);
                final role = AdminRole.fromString(roleValue);
                await ref.read(adminSessionProvider.notifier).switchRole(role);
              }
            },
          ),
        ],
      ),
    );
  }
}
