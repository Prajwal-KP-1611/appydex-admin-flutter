import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/admin_config.dart';
import 'core/auth/auth_service.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'features/admins/admins_list_screen.dart';
import 'features/audit/audit_logs_screen.dart';
import 'features/auth/change_password_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/diagnostics/diagnostics_screen.dart';
import 'features/service_type_requests/requests_list_screen.dart';
import 'features/services/services_list_screen.dart';
import 'features/subscriptions/subscriptions_admin_screen.dart';
import 'features/vendors/vendor_detail_screen.dart';
import 'features/vendors/vendors_list_screen.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load(flavor: kAppFlavor);

  // Force reset to localhost for development
  await config.clearApiBaseUrl();

  // Load admin token from preferences
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
}

class AppydexAdminApp extends ConsumerStatefulWidget {
  const AppydexAdminApp({super.key});

  @override
  ConsumerState<AppydexAdminApp> createState() => _AppydexAdminAppState();
}

class _AppydexAdminAppState extends ConsumerState<AppydexAdminApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth session on app start
    Future.microtask(() {
      ref.read(adminSessionProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final baseUrl = ref.watch(apiBaseUrlProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      title: 'AppyDex Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: config.flavor == 'test'
          ? '/diagnostics'
          : (isAuthenticated ? AppRoute.dashboard.path : '/login'),
      onGenerateRoute: (settings) {
        // Check authentication for protected routes
        final protectedRoutes = <String>[
          '/',
          '/dashboard',
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
