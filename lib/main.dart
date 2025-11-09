import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/admin_config.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'core/navigation/app_route_observer.dart';
import 'core/navigation/last_route.dart';
import 'features/admins/admins_list_screen.dart';
import 'features/audit/audit_logs_screen.dart';
import 'features/auth/change_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/diagnostics/diagnostics_screen.dart';
import 'features/plans/plans_list_screen.dart';
import 'features/service_type_requests/requests_list_screen.dart';
import 'features/services/services_list_screen.dart';
import 'features/subscriptions/subscriptions_admin_screen.dart';
import 'features/vendors/vendor_detail_screen.dart';
import 'features/vendors/vendors_list_screen.dart';
import 'features/users/users_list_screen.dart';
import 'features/payments/payments_list_screen.dart';
import 'features/analytics/analytics_dashboard_screen.dart';
import 'features/campaigns/referrals_screen.dart';
import 'features/reviews/reviews_list_screen.dart';
import 'features/reviews/vendor_flags_queue_screen.dart';
import 'features/system/system_health_screen.dart';
import 'routes.dart';

// Provided via --dart-define at build time. Empty disables Sentry.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

// API base override for diagnostics (optional)
const _apiBaseOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = kAppFlavor;
      options.release = 'appydex-admin@$kAppVersion';
      // Performance tracing (lower in prod to reduce cost)
      options.tracesSampleRate = kAppFlavor == 'prod' ? 0.15 : 0.4;
      options.debug = kAppFlavor != 'prod';
      options.beforeSend = (event, hint) {
        // Scrub sensitive headers (request is guaranteed non-null here)
        if (event.request != null) {
          event.request!.headers.remove('authorization');
          event.request!.headers.remove('x-admin-token');
        }
        return event;
      };
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      assertProdConfig();

      final config = await AppConfig.load(flavor: kAppFlavor);
      if (_apiBaseOverride.isNotEmpty) {
        await config.setApiBaseUrl(_apiBaseOverride);
        // Debug only (avoid print spam in prod) – flagged by analyzer but acceptable here.
        // ignore: avoid_print
        print('🌐 API Base URL overridden via dart define: ${config.apiBaseUrl}');
      } else {
        // ignore: avoid_print
        print('🌐 API Base URL resolved: ${config.apiBaseUrl}');
      }
      // ignore: avoid_print
      print('🏗️  Build flavor: $kAppFlavor');
      // ignore: avoid_print
      print('📦 App version: $kAppVersion');
      // ignore: avoid_print
      print('🔧 Mock mode: ${config.mockMode}');
      if (_sentryDsn.isNotEmpty) {
        // ignore: avoid_print
        print('�️  Sentry enabled for $kAppFlavor');
      } else {
        // ignore: avoid_print
        print('⚠️  Sentry DSN missing – monitoring disabled');
      }

      // Legacy admin token (kept for backward compatibility if present)
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('admin_token');
      if (adminToken != null && adminToken.isNotEmpty) {
        AdminConfig.adminToken = adminToken;
      }

      runApp(
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(config)],
          child: const AppydexAdminApp(),
        ),
      );
    },
  );
}

class AppydexAdminApp extends ConsumerStatefulWidget {
  const AppydexAdminApp({super.key});

  @override
  ConsumerState<AppydexAdminApp> createState() => _AppydexAdminAppState();
}

class _AppydexAdminAppState extends ConsumerState<AppydexAdminApp> {
  bool _sessionInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check if we already have a session (hot reload case)
    final currentSession = ref.read(adminSessionProvider);
    if (currentSession != null) {
      _sessionInitialized = true;
    } else {
      // Only initialize if we don't have a session
      Future.microtask(() async {
        await ref.read(adminSessionProvider.notifier).initialize();
        if (mounted) {
          setState(() => _sessionInitialized = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final baseUrl = ref.watch(apiBaseUrlProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Show loading screen while session is being restored
    if (!_sessionInitialized && config.flavor != 'test') {
      return MaterialApp(
        title: 'AppyDex Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Determine initial screen based on auth state
    String initialRoute;
    if (config.flavor == 'test') {
      initialRoute = '/diagnostics';
    } else if (isAuthenticated) {
      // Try to restore the current URL from browser hash, else dashboard
      // If the hash is "/login" but we're already authenticated, force dashboard.
      final urlHash = LastRoute.resolveInitialRoute();
      if (urlHash == '/login') {
        initialRoute = AppRoute.dashboard.path;
      } else {
        initialRoute = urlHash ?? AppRoute.dashboard.path;
      }
    } else {
      initialRoute = '/login';
    }

    return MaterialApp(
      key: ValueKey('app_$_sessionInitialized'),
      title: 'AppyDex Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      navigatorObservers: [appRouteObserver],
      onGenerateRoute: (settings) {
        // Check authentication for protected routes
        final protectedRoutes = <String>[
          '/',
          '/dashboard',
          '/analytics',
          '/vendors',
          '/vendors/detail',
          '/subscriptions',
          '/audit',
          '/diagnostics',
          '/users',
          '/services',
          '/service-type-requests',
          '/plans',
          '/campaigns',
          '/reviews',
          '/payments',
          '/reports',
          '/admins',
        ];

        // In test flavor, allow diagnostics without auth for widget tests
        final flavor = config.flavor;
        if (flavor == 'test') {
          protectedRoutes.remove('/diagnostics');
        }

        if (protectedRoutes.contains(settings.name) && !isAuthenticated) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const LoginScreen(),
          );
        }

        switch (settings.name) {
          case '/login':
            // If already authenticated, redirect away from login to dashboard
            if (isAuthenticated) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const DashboardScreen(),
              );
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/change-password':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ChangePasswordScreen(),
            );
          case '/':
          case '/dashboard':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DashboardScreen(),
            );
          case '/analytics':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AnalyticsDashboardScreen(),
            );
          case '/vendors':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) =>
                  VendorsListScreen(initialArguments: settings.arguments),
            );
          case '/vendors/detail':
            final args = settings.arguments as VendorDetailArgs?;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => VendorDetailScreen(args: args),
            );
          case '/subscriptions':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SubscriptionsAdminScreen(),
            );
          case '/audit':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AuditLogsScreen(),
            );
          case '/diagnostics':
            // Hide diagnostics route in production
            if (kAppFlavor == 'prod') {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const DashboardScreen(),
              );
            }
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => DiagnosticsScreen(initialBaseUrl: baseUrl),
            );
          case '/admins':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const AdminsListScreen(),
            );
          case '/services':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ServicesListScreen(),
            );
          case '/service-type-requests':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ServiceTypeRequestsListScreen(),
            );
          case '/plans':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PlansListScreen(),
            );
          case '/users':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const UsersListScreen(),
            );
          case '/payments':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const PaymentsListScreen(),
            );
          case '/campaigns':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) =>
                  const ReferralsScreen(), // placeholder campaigns hub
            );
          case '/reviews':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ReviewsListScreen(),
            );
          case '/reviews/flags':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const VendorFlagsQueueScreen(),
            );
          case '/reports':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SystemHealthScreen(),
            );
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DashboardScreen(),
            );
        }
      },
    );
  }
}
