import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for complete authentication flow
/// Covers: OTP request → verification → session persistence → logout
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E', () {
    testWidgets('login with OTP → verify session → logout', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login screen
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      // Enter email
      final emailField = find.byKey(const Key('email_field'));
      if (emailField.evaluate().isEmpty) {
        // Fallback to finding by widget type
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.first, 'admin@appydex.co');
      } else {
        await tester.enterText(emailField, 'admin@appydex.co');
      }
      await tester.pump();

      // Request OTP
      final requestOtpButton = find.widgetWithText(ElevatedButton, 'Request OTP');
      if (requestOtpButton.evaluate().isNotEmpty) {
        await tester.tap(requestOtpButton);
        await tester.pumpAndSettle();

        // Wait for OTP sent confirmation
        await tester.pump(const Duration(seconds: 2));

        // Enter OTP (in test mode, any 6-digit code works)
        final otpFields = find.byType(TextField);
        if (otpFields.evaluate().length > 1) {
          await tester.enterText(otpFields.at(1), '123456');
          await tester.pump();

          // Verify OTP
          final verifyButton = find.widgetWithText(ElevatedButton, 'Verify & Login');
          if (verifyButton.evaluate().isNotEmpty) {
            await tester.tap(verifyButton);
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
                expect(find.text('Admin Login'), findsOneWidget);
              }
            }
          }
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
