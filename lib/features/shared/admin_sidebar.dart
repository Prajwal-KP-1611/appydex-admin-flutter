import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes.dart';

class AdminScaffold extends ConsumerWidget {
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
    final navItems = _navigationItems;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 1000;
        final appBar = AppBar(
          title: Text(title ?? _labelFor(currentRoute)),
          actions: actions,
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
                                              .withOpacity(0.6),
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
                          children: [
                            // Dashboard (no section)
                            _buildNavItem(
                              context,
                              _navigationItems[0],
                              currentRoute,
                            ),
                            const SizedBox(height: 8),

                            // MANAGEMENT Section
                            _buildSectionHeader(context, 'MANAGEMENT'),
                            _buildNavItem(
                              context,
                              _navigationItems[1],
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _navigationItems[2],
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder - users route
                                'Users',
                                Icons.people_outline,
                                section: 'management',
                              ),
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _navigationItems[3],
                              currentRoute,
                            ),
                            const SizedBox(height: 8),

                            // COMMERCE Section
                            _buildSectionHeader(context, 'COMMERCE'),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder
                                'Subscription Plans',
                                Icons.card_membership_outlined,
                                section: 'commerce',
                              ),
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _navigationItems[4],
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder
                                'Payments',
                                Icons.payment_outlined,
                                section: 'commerce',
                              ),
                              currentRoute,
                            ),
                            const SizedBox(height: 8),

                            // ENGAGEMENT Section
                            _buildSectionHeader(context, 'ENGAGEMENT'),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder
                                'Campaigns',
                                Icons.campaign_outlined,
                                section: 'engagement',
                              ),
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder
                                'Reviews',
                                Icons.rate_review_outlined,
                                section: 'engagement',
                              ),
                              currentRoute,
                            ),
                            const SizedBox(height: 8),

                            // SYSTEM Section
                            _buildSectionHeader(context, 'SYSTEM'),
                            _buildNavItem(
                              context,
                              _navigationItems[5],
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _AdminNavItem(
                                AppRoute.dashboard, // Placeholder
                                'Reports',
                                Icons.assessment_outlined,
                                section: 'system',
                              ),
                              currentRoute,
                            ),
                            _buildNavItem(
                              context,
                              _navigationItems[6],
                              currentRoute,
                            ),
                          ],
                        ),
                      ),
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
                for (final item in navItems)
                  ListTile(
                    selected: item.route == currentRoute,
                    leading: Icon(item.icon),
                    title: Text(item.label),
                    onTap: () {
                      Navigator.pop(context);
                      _navigate(context, item);
                    },
                  ),
              ],
            ),
          ),
          body: child,
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    return _navigationItems
        .firstWhere(
          (item) => item.route == route,
          orElse: () => _navigationItems.first,
        )
        .label;
  }

  void _navigate(BuildContext context, _AdminNavItem item) {
    if (ModalRoute.of(context)?.settings.name == item.route.path) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(item.route.path);
  }
}

class _AdminNavItem {
  const _AdminNavItem(this.route, this.label, this.icon, {this.section});

  final AppRoute route;
  final String label;
  final IconData icon;
  final String? section;
}

const _navigationItems = [
  _AdminNavItem(AppRoute.dashboard, 'Dashboard', Icons.dashboard_outlined),
  _AdminNavItem(
    AppRoute.admins,
    'Admin Users',
    Icons.admin_panel_settings_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.vendors,
    'Vendors',
    Icons.storefront_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.services,
    'Service Catalog',
    Icons.category_outlined,
    section: 'management',
  ),
  _AdminNavItem(
    AppRoute.subscriptions,
    'Subscriptions',
    Icons.credit_card_outlined,
    section: 'commerce',
  ),
  _AdminNavItem(
    AppRoute.audit,
    'Audit Logs',
    Icons.history_outlined,
    section: 'system',
  ),
  _AdminNavItem(
    AppRoute.diagnostics,
    'Diagnostics',
    Icons.medical_services_outlined,
    section: 'system',
  ),
];
