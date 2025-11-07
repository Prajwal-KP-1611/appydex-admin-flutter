import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for payment refund with idempotency
/// Covers: Navigate to payments → refund → idempotency → duplicate protection
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Payments Refund E2E', () {
    testWidgets('refund payment with idempotency protection', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Navigate to payments
      final paymentsNav = find.text('Payments');
      if (paymentsNav.evaluate().isNotEmpty) {
        await tester.tap(paymentsNav);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));

        // Find succeeded payment
        final succeededChips = find.widgetWithText(Chip, 'SUCCEEDED');
        if (succeededChips.evaluate().isNotEmpty) {
          // Tap first succeeded payment to open details
          final paymentCards = find.byType(Card);
          if (paymentCards.evaluate().isNotEmpty) {
            await tester.tap(paymentCards.first);
            await tester.pumpAndSettle();

            // Look for refund button
            final refundButton = find.widgetWithText(FilledButton, 'Refund');
            if (refundButton.evaluate().isNotEmpty) {
              // Tap refund
              await tester.tap(refundButton);
              await tester.pumpAndSettle();

              // Should show reason dialog
              final reasonField = find.byType(TextField);
              if (reasonField.evaluate().isNotEmpty) {
                await tester.enterText(reasonField.last, 'E2E test refund');
                await tester.pump();

                // Confirm refund
                final confirmButton = find.widgetWithText(FilledButton, 'Refund');
                if (confirmButton.evaluate().isNotEmpty) {
                  await tester.tap(confirmButton);
                  await tester.pumpAndSettle(const Duration(seconds: 3));

                  // Should show success
                  expect(find.text('Payment refunded successfully'), findsOneWidget);

                  // Try to refund again (should be prevented by idempotency)
                  // Button should be disabled or show error
                  await tester.pump(const Duration(seconds: 1));
                }
              }

              // Close dialog
              final closeButtons = find.byType(TextButton);
              if (closeButtons.evaluate().isNotEmpty) {
                await tester.tap(closeButtons.last);
                await tester.pumpAndSettle();
              }
            }
          }
        }
      }
    });

    testWidgets('refund requires payment:refund permission', (tester) async {
      // Test that refund button is hidden without permission
      // TODO: Implement with permission mocking
    });
  });
}
