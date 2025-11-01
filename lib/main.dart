import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/config.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/diagnostics/diagnostics_screen.dart';
import 'features/subscriptions/subscriptions_admin_screen.dart';
import 'features/vendors/vendor_detail_screen.dart';
import 'features/vendors/vendors_list_screen.dart';
import 'features/audit/audit_logs_screen.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.load(flavor: kAppFlavor);

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const AppydexAdminApp(),
    ),
  );
}

class AppydexAdminApp extends ConsumerWidget {
  const AppydexAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = _buildTheme();
    final baseUrl = ref.watch(apiBaseUrlProvider);

    return MaterialApp(
      title: 'Appydex Admin',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: AppRoute.dashboard.path,
      onGenerateRoute: (settings) {
        switch (settings.name) {
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
          default:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DashboardScreen(),
            );
        }
      },
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF0B5FFF);
    const onPrimary = Color(0xFFFFFFFF);
    const background = Color(0xFFF6F8FF);
    const surface = Color(0xFFFFFFFF);
    const surfaceVariant = Color(0xFFF3F4F6);
    const errorColor = Color(0xFFE12D2D);

    final defaultRadius = BorderRadius.circular(12);
    final cardShape = RoundedRectangleBorder(borderRadius: defaultRadius);

    final colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      onPrimary: onPrimary,
      surface: surface,
      surfaceTint: primaryColor,
      surfaceContainerHighest: surfaceVariant,
      onSurface: Colors.black,
      error: errorColor,
      onError: onPrimary,
      secondary: Color(0xFF12B0FF),
    );

    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardThemeData(color: surface, elevation: 0, shape: cardShape),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: defaultRadius),
      ),
    );
  }
}
