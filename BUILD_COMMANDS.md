# Quick Build Commands

## Staging

```bash
flutter build web \
  --dart-define=APP_FLAVOR=staging \
  --dart-define=APP_VERSION=$(git rev-parse --short HEAD) \
  --dart-define=API_BASE_URL=https://api-staging.appydex.co \
  --dart-define=SENTRY_DSN=$STAGING_SENTRY_DSN \
  --release \
  --web-renderer canvaskit \
  --source-maps
```

## Production

```bash
flutter build web \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=API_BASE_URL=https://api.appydex.co \
  --dart-define=SENTRY_DSN=$PROD_SENTRY_DSN \
  --release \
  --web-renderer canvaskit \
  --source-maps
```

## Local Dev

```bash
flutter run -d chrome \
  --dart-define=APP_FLAVOR=dev \
  --dart-define=API_BASE_URL=http://localhost:16110 \
  --dart-define=SENTRY_DSN= \
  --dart-define=APP_VERSION=dev-local
```

## Test Commands

```bash
# Unit tests
flutter test --coverage

# Integration tests
cd integration_test && ./run_tests.sh

# Analyze
flutter analyze --fatal-infos

# Format check
dart format --set-exit-if-changed lib/ test/
```

## Git Tag for Production

```bash
git tag v1.0.0
git push origin v1.0.0  # Triggers GitHub Actions deploy
```

## Security Header Check

```bash
curl -I https://admin.appydex.com | grep -E "(Content-Security-Policy|Strict-Transport|X-Frame)"
```

## Sentry Test

```dart
// Add to any screen temporarily
throw Exception('Test Sentry integration');
```
