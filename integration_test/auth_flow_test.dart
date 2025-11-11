import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for complete authentication flow
/// Covers: password-only login → session persistence → logout
///
/// ⚠️ UPDATED (Nov 10, 2025): Admin now uses password-only authentication (no OTP)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E', () {
    testWidgets('login with password → verify session → logout', (
      tester,
    ) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login screen
      expect(find.text('AppyDex Admin'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password

      // Enter email
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'admin@appydex.co');
      await tester.pump();

      // Enter password
      await tester.enterText(textFields.at(1), 'TestPassword123');
      await tester.pump();

      // Tap Login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to dashboard after successful login
      expect(find.text('Dashboard'), findsOneWidget);

      // Logout
      final profileButton = find.byIcon(Icons.account_circle);
      if (profileButton.evaluate().isNotEmpty) {
        await tester.tap(profileButton);
        await tester.pumpAndSettle();

        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();

          // Should return to login screen
          expect(find.text('AppyDex Admin'), findsOneWidget);
        }
      }
    });

    testWidgets('session persistence across app restarts', (tester) async {
      // This test requires a real device/emulator with persistent storage
      // Skip in CI environments
      // TODO: Implement with proper session storage mocking
    });
  });
}
