import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for review moderation and takedown
/// Covers: Reviews list → approve/hide/remove actions → flags queue → resolve
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reviews Takedown E2E', () {
    testWidgets('review moderation actions work correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Navigate to reviews
      final reviewsNav = find.text('Reviews');
      if (reviewsNav.evaluate().isEmpty) {
        final reviewsNavAlt = find.textContaining('Review');
        if (reviewsNavAlt.evaluate().isNotEmpty) {
          await tester.tap(reviewsNavAlt.first);
        }
      } else {
        await tester.tap(reviewsNav);
      }
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Find a pending review
      final pendingSegment = find.widgetWithText(ButtonSegment, 'Pending');
      if (pendingSegment.evaluate().isNotEmpty) {
        await tester.tap(pendingSegment);
        await tester.pumpAndSettle();

        // Find first review card
        final reviewCards = find.byType(Card);
        if (reviewCards.evaluate().isNotEmpty) {
          // Find approve button
          final approveButtons = find.widgetWithText(FilledButton, 'Approve');
          if (approveButtons.evaluate().isNotEmpty) {
            await tester.tap(approveButtons.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Should show success message
            expect(find.text('Review approved'), findsOneWidget);

            // Now hide the review
            await tester.pump(const Duration(seconds: 1));
            final hideButtons = find.widgetWithText(OutlinedButton, 'Hide');
            if (hideButtons.evaluate().isNotEmpty) {
              await tester.tap(hideButtons.first);
              await tester.pumpAndSettle();

              // Enter reason
              final reasonField = find.byType(TextField);
              if (reasonField.evaluate().isNotEmpty) {
                await tester.enterText(reasonField.last, 'E2E test hide');
                await tester.pump();

                final confirmButton = find.widgetWithText(FilledButton, 'Confirm');
                if (confirmButton.evaluate().isNotEmpty) {
                  await tester.tap(confirmButton);
                  await tester.pumpAndSettle(const Duration(seconds: 2));
                }
              }
            }

            // Test restore
            final restoreButtons = find.widgetWithText(OutlinedButton, 'Restore');
            if (restoreButtons.evaluate().isNotEmpty) {
              await tester.tap(restoreButtons.first);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              expect(find.text('Review restored'), findsOneWidget);
            }
          }
        }
      }
    });

    testWidgets('vendor flags queue and resolve', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Navigate to reviews
      final reviewsNav = find.text('Reviews');
      if (reviewsNav.evaluate().isNotEmpty) {
        await tester.tap(reviewsNav);
        await tester.pumpAndSettle();

        // Find flags queue button
        final flagsQueueButton = find.widgetWithText(OutlinedButton, 'Flags Queue');
        if (flagsQueueButton.evaluate().isNotEmpty) {
          await tester.tap(flagsQueueButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should show flagged reviews screen
          expect(find.text('Vendor Flags Queue'), findsOneWidget);

          // Look for flagged review cards
          final flagIcons = find.byIcon(Icons.flag);
          if (flagIcons.evaluate().isNotEmpty) {
            // Find action buttons (approve/hide/remove)
            final actionButtons = find.byType(IconButton);
            if (actionButtons.evaluate().isNotEmpty) {
              // Test approve action
              final approveIcons = find.byIcon(Icons.check_circle);
              if (approveIcons.evaluate().isNotEmpty) {
                await tester.tap(approveIcons.first);
                await tester.pumpAndSettle(const Duration(seconds: 2));
                // Should show progress or success
              }
            }
          }
        }
      }
    });

    testWidgets('review actions require reviews:update permission', (tester) async {
      // Test that action buttons are hidden without permission
      // TODO: Implement with permission mocking
    });
  });
}
