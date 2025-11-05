import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'last_route.dart';

/// Global route observer used to persist last visited route path.
final RouteObserver<PageRoute<dynamic>> appRouteObserver = AppRouteObserver();

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _persist(Route<dynamic>? route) async {
    if (route is PageRoute) {
      final name = route.settings.name;
      if (name != null && name.startsWith('/')) {
        await LastRoute.write(name);
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _persist(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _persist(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _persist(previousRoute);
  }
}
