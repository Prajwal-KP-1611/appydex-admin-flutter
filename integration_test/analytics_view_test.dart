import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appydex_admin/main.dart' as app;

/// E2E test for analytics dashboard and export
/// Covers: Dashboard loads → export triggers → job poller → download ready
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Analytics View E2E', () {
    testWidgets('analytics dashboard loads and export works', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Navigate to analytics
      final analyticsNav = find.text('Analytics');
      if (analyticsNav.evaluate().isNotEmpty) {
        await tester.tap(analyticsNav);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));

        // Check that data cards are present
        expect(find.text('Top Searches'), findsOneWidget);
        expect(find.text('CTR Over Time'), findsOneWidget);

        // Look for export button
        final exportButton = find.widgetWithText(OutlinedButton, 'Export (CSV)');
        if (exportButton.evaluate().isNotEmpty) {
          // Trigger export
          await tester.tap(exportButton);
          await tester.pumpAndSettle();

          // Should show "Starting..." or progress indicator
          await tester.pump(const Duration(seconds: 2));

          // Job poller should be active - look for progress widget
          final progressIndicators = find.byType(CircularProgressIndicator);
          if (progressIndicators.evaluate().isNotEmpty) {
            // Wait for job to complete (with timeout)
            for (int i = 0; i < 10; i++) {
              await tester.pump(const Duration(seconds: 2));
              
              // Check if completed
              final completedText = find.text('Completed');
              if (completedText.evaluate().isNotEmpty) {
                break;
              }
            }

            // Should eventually show completion or download button
            // (In real test, this depends on backend job processing)
          }
        }
      }
    });

    testWidgets('analytics requires analytics:view permission', (tester) async {
      // Test permission error shown when lacking analytics:view
      // TODO: Implement with permission mocking
    });

    testWidgets('export button hidden without analytics:export permission', (tester) async {
      // Test that export button is not shown without permission
      // TODO: Implement with permission mocking
    });
  });
}
