# Integration Tests

End-to-end tests for AppyDex Admin Panel critical flows.

## Prerequisites

1. **Backend API Running**: Ensure staging/test backend is accessible at configured API URL
2. **Test Admin Account**: Valid admin credentials with full permissions
3. **Test Data**: Some test vendors, payments, and reviews in the database

## Test Files

- `auth_flow_test.dart` - OTP login → session → logout
- `vendors_verify_test.dart` - Vendor verification with idempotency
- `payments_refund_test.dart` - Payment refund with duplicate protection
- `analytics_view_test.dart` - Dashboard load and export job polling
- `reviews_takedown_test.dart` - Review moderation and flags queue

## Running Tests

### Web (Chrome)
```bash
flutter test integration_test/auth_flow_test.dart --dart-define=API_BASE_URL=https://api.appydex.co
```

### Android/iOS
```bash
flutter test integration_test --device-id=<device_id>
```

### All Integration Tests
```bash
flutter test integration_test/
```

## Test Structure

Each test follows this pattern:

1. **Setup**: Launch app, wait for initialization
2. **Navigation**: Navigate to feature screen
3. **Interaction**: Perform user actions (tap, type, etc.)
4. **Assertion**: Verify expected outcomes
5. **Cleanup**: Return to known state

## Important Notes

### Idempotency Testing
Tests verify that actions protected by `Idempotency-Key` headers (refunds, verifications) don't create duplicates on retry.

### Permission Testing
Several tests include TODOs for permission-gated behavior. These require:
- Switching to a restricted admin account
- Mocking permission responses
- Verifying UI elements are hidden/disabled

### Job Polling
Analytics export test demonstrates the `JobPoller` widget behavior:
- Initiates export job
- Polls for completion
- Shows download link when ready

### Timing
Tests use `pumpAndSettle()` and manual delays to handle:
- Network requests
- State updates
- Animations
- Backend processing

Adjust timeouts in `Duration(seconds: X)` if running against slow networks.

## CI/CD Integration

To run in CI pipelines:

```yaml
test:
  script:
    - flutter test integration_test/ --dart-define=API_BASE_URL=$STAGING_API_URL
  artifacts:
    when: always
    paths:
      - integration_test/screenshots/
```

## Troubleshooting

### "Widget not found"
- Increase wait times with `await tester.pump(Duration(seconds: N))`
- Use `find.textContaining()` or `find.byType()` for flexible matching
- Print widget tree: `debugDumpApp()` or `debugDumpRenderTree()`

### "Network request failed"
- Verify backend is accessible from test environment
- Check API_BASE_URL configuration
- Ensure CORS allows test origin

### "Test timeout"
- Extend test timeout: `testWidgets(..., timeout: Timeout(Duration(minutes: 5)))`
- Reduce polling intervals in tests
- Check for infinite loops in app code

## Future Enhancements

- [ ] Screenshot capture on failure
- [ ] Test data seeding script
- [ ] Permission mocking utilities
- [ ] Parallel test execution
- [ ] Performance benchmarking
- [ ] Visual regression testing
