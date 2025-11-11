import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../routes.dart';
import '../../core/navigation/last_route.dart';

class AdminScaffold extends ConsumerWidget {
  List<Widget> _buildSectionedNav(BuildContext context, AppRoute currentRoute) {
    final widgets = <Widget>[];
    // Filter out unavailable routes (like diagnostics in prod)
    final availableNavItems = _allNavItems
        .where((item) => item.route.isAvailable)
        .toList();

    // Dashboard
    widgets.add(_buildNavItem(context, availableNavItems.first, currentRoute));
    widgets.add(const SizedBox(height: 8));

    Widget section(String name) => _buildSectionHeader(context, name);

    // Management
    widgets.add(section('MANAGEMENT'));
    for (final item in availableNavItems.where(
      (i) => i.section == 'management',
    )) {
      widgets.add(_buildNavItem(context, item, currentRoute));
    }
    widgets.add(const SizedBox(height: 8));

    // Commerce
    widgets.add(section('COMMERCE'));
    for (final item in availableNavItems.where(
      (i) => i.section == 'commerce',
    )) {
      widgets.add(_buildNavItem(context, item, currentRoute));
    }
    widgets.add(const SizedBox(height: 8));

    // Engagement
    widgets.add(section('ENGAGEMENT'));
    for (final item in availableNavItems.where(
      (i) => i.section == 'engagement',
    )) {
      widgets.add(_buildNavItem(context, item, currentRoute));
    }
    widgets.add(const SizedBox(height: 8));

    // System
    widgets.add(section('SYSTEM'));
    for (final item in availableNavItems.where((i) => i.section == 'system')) {
      widgets.add(_buildNavItem(context, item, currentRoute));
    }

    return widgets;
  }

  List<Widget> _buildDrawerItems(BuildContext context, AppRoute currentRoute) {
    // Filter out unavailable routes (like diagnostics in prod)
    final availableNavItems = _allNavItems
        .where((item) => item.route.isAvailable)
        .toList();

    final items = <Widget>[];
    for (var i = 0; i < availableNavItems.length; i++) {
      final item = availableNavItems[i];
      if (i == 0) {
        // Dashboard (no header)
      } else {
        final prev = availableNavItems[i - 1];
        if (item.section != prev.section && item.section != null) {
          items.add(_buildSectionHeader(context, item.section!.toUpperCase()));
        }
      }
      items.add(
        ListTile(
          selected: item.route == currentRoute,
          leading: Icon(item.icon),
          title: Text(item.label),
          onTap: () {
            Navigator.pop(context);
            _navigate(context, item);
          },
        ),
      );
    }
    return items;
  }

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.child,
    this.title,
    this.actions = const [],
  });

  final AppRoute currentRoute;
  final Widget child;
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use canonical nav item list for both sidebar and drawer
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 1000;

        // Build environment chip
        final envChip = _buildEnvironmentChip(context);

        final appBar = AppBar(
          title: Text(title ?? _labelFor(currentRoute)),
          actions: [
            if (envChip != null) ...[envChip, const SizedBox(width: 8)],
            ...actions,
          ],
        );

        if (useRail) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                // Enhanced sidebar with more details
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Sidebar header
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.apps,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AppyDex',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Admin Panel',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Navigation items with sections
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: _buildSectionedNav(context, currentRoute),
                        ),
                      ),
                      // Logout button at bottom
                      const Divider(height: 1),
                      _buildLogoutButton(context, ref),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Text(
                    'Appydex Admin',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                ..._buildDrawerItems(context, currentRoute),
              ],
            ),
          ),
          body: child,
        );
      },
    );
  }

  Widget? _buildEnvironmentChip(BuildContext context) {
    // Always hide environment chip
    return null;
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    _AdminNavItem item,
    AppRoute currentRoute,
  ) {
    final isSelected = item.route == currentRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(0.1),
        leading: Icon(
          item.icon,
          size: 20,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () => _navigate(context, item),
      ),
    );
  }

  String _labelFor(AppRoute route) {
    return _allNavItems
        .firstWhere(
          (item) => item.route == route,
          orElse: () => _allNavItems.first,
        )
        .label;
  }

  void _navigate(BuildContext context, _AdminNavItem item) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == item.route.path) {
      return;
    }
    // Persist last route to enable restore-after-reload
    // ignore: unawaited_futures
    LastRoute.write(item.route.path);
    Navigator.of(context).pushReplacementNamed(item.route.path);
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final session = ref.watch(adminSessionProvider);
    final email = session?.email ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.activeRole.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  debugPrint('[Logout] Button clicked');

                  if (!context.mounted) {
                    debugPrint('[Logout] Context not mounted, aborting');
                    return;
                  }

                  // Get navigator before logout changes state
                  final navigator = Navigator.of(context);
                  debugPrint('[Logout] Navigator obtained');

                  // Perform logout
                  debugPrint('[Logout] Calling logout...');
                  await ref.read(adminSessionProvider.notifier).logout();
                  debugPrint('[Logout] Logout complete');

                  // Small delay to ensure state updates
                  await Future.delayed(const Duration(milliseconds: 50));

                  // Clear entire navigation stack and go to login
                  debugPrint('[Logout] Navigating to login...');
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                  debugPrint('[Logout] Navigation initiated');
                } catch (e, stack) {
                  debugPrint('[Logout] Error during logout: $e');
                  debugPrint('[Logout] Stack trace: $stack');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem {
  const _AdminNavItem(this.route, this.label, this.icon, {this.section});

  final AppRoute route;
  final String label;
  final IconData icon;
  final String? section;
}

const _allNavItems = [
  _AdminNavItem(AppRoute.dashboard, 'Dashboard', Icons.dashboard_outlined),
  _AdminNavItem(
    AppRoute.analytics,
    'Analytics',
    Icons.analytics_outlined,
    section: 'management', // grouped under management for now
  ),
  _AdminNavItem(
    AppRoute.admins,
    'Admin Users',
    Icons.admin_panel_settings_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.vendorOnboarding,
    'Vendor Onboarding',
    Icons.how_to_reg_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.vendorManagement,
    'Vendor Management',
    Icons.storefront_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.users,
    'Users',
    Icons.people_outline,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.services,
    'Service Catalog',
    Icons.category_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.serviceTypeRequests,
    'Service Type Requests',
    Icons.pending_actions_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.plans,
    'Subscription Plans',
    Icons.card_membership_outlined,
    section: 'commerce',
  ),
  _AdminNavItem(
    AppRoute.subscriptions,
    'Subscriptions',
    Icons.credit_card_outlined,
    section: 'commerce',
  ),
  _AdminNavItem(
    AppRoute.payments,
    'Payments',
    Icons.payment_outlined,
    section: 'commerce',
  ),
  _AdminNavItem(
    AppRoute.campaigns,
    'Campaigns',
    Icons.campaign_outlined,
    section: 'engagement',
  ),
  _AdminNavItem(
    AppRoute.reviews,
    'Reviews',
    Icons.rate_review_outlined,
    section: 'engagement',
  ),
  _AdminNavItem(
    AppRoute.feedback,
    'Feedback',
    Icons.feedback_outlined,
    section: 'engagement',
  ),
  _AdminNavItem(
    AppRoute.audit,
    'Audit Logs',
    Icons.history_outlined,
    section: 'system',
  ),
  _AdminNavItem(
    AppRoute.reports,
    'Reports',
    Icons.assessment_outlined,
    section: 'system',
  ),
  _AdminNavItem(
    AppRoute.diagnostics,
    'Diagnostics',
    Icons.medical_services_outlined,
    section: 'system',
  ),
];
