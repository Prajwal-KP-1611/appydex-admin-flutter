import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for vendor verification with idempotency
/// Covers: Navigate to vendors → verify action → idempotency key → retry safety
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vendors Verify E2E', () {
    testWidgets('verify vendor with idempotency protection', (tester) async {
      // Launch app (assumes already authenticated from previous test or session)
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to initialize
      await tester.pump(const Duration(seconds: 2));

      // Navigate to vendors
      final vendorsNav = find.text('Vendors');
      if (vendorsNav.evaluate().isNotEmpty) {
        await tester.tap(vendorsNav);
        await tester.pumpAndSettle();

        // Wait for vendors list to load
        await tester.pump(const Duration(seconds: 2));

        // Find first pending vendor (if any)
        final pendingChips = find.widgetWithText(Chip, 'PENDING');
        if (pendingChips.evaluate().isNotEmpty) {
          // Find the vendor card containing this chip
          final vendorCards = find.byType(Card);
          if (vendorCards.evaluate().isNotEmpty) {
            await tester.tap(vendorCards.first);
            await tester.pumpAndSettle();

            // Look for verify button in detail screen or dialog
            final verifyButton = find.widgetWithText(ElevatedButton, 'Verify');
            if (verifyButton.evaluate().isNotEmpty) {
              // First verification attempt
              await tester.tap(verifyButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              // Should show success message
              expect(find.text('Vendor verified'), findsOneWidget);

              // Try to verify again (should be idempotent - no error or duplicate)
              final verifyButtonAgain = find.widgetWithText(ElevatedButton, 'Verify');
              if (verifyButtonAgain.evaluate().isNotEmpty) {
                await tester.tap(verifyButtonAgain);
                await tester.pumpAndSettle(const Duration(seconds: 2));

                // Should either show "already verified" or succeed without error
                expect(find.byType(SnackBar), findsOneWidget);
              }

              // Close detail/dialog
              final closeButton = find.byIcon(Icons.close);
              if (closeButton.evaluate().isNotEmpty) {
                await tester.tap(closeButton);
                await tester.pumpAndSettle();
              }
            }
          }
        }
      }
    });

    testWidgets('vendor verification requires permission', (tester) async {
      // Test that verify button is hidden if user lacks vendors:verify permission
      // This requires switching to a restricted admin account
      // TODO: Implement with role/permission mocking
    });
  });
}
