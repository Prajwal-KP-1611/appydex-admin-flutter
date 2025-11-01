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
                NavigationRail(
                  selectedIndex: _indexFor(currentRoute),
                  onDestinationSelected: (index) =>
                      _navigate(context, navItems[index]),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final item in navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
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

  int _indexFor(AppRoute route) {
    return _navigationItems.indexWhere((element) => element.route == route);
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
  const _AdminNavItem(this.route, this.label, this.icon);

  final AppRoute route;
  final String label;
  final IconData icon;
}

const _navigationItems = [
  _AdminNavItem(AppRoute.dashboard, 'Dashboard', Icons.dashboard_outlined),
  _AdminNavItem(AppRoute.vendors, 'Vendors', Icons.storefront_outlined),
  _AdminNavItem(AppRoute.subscriptions, 'Subscriptions', Icons.credit_card),
  _AdminNavItem(AppRoute.audit, 'Audit Logs', Icons.auto_stories_outlined),
  _AdminNavItem(
    AppRoute.diagnostics,
    'Diagnostics',
    Icons.medical_services_outlined,
  ),
];
