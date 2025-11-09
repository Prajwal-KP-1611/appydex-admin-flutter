# Production Configuration Change Points

**⚠️ CRITICAL: Update these before deploying to production**

This document lists every file and configuration that must be changed when moving from local development to production deployment.

---

## 🔴 CRITICAL CHANGES (Must Do)

### 1. API Base URL Configuration

**File:** `lib/core/config.dart`  
**Line:** ~6

**Current (Local Development):**
```dart
const kDefaultApiBaseUrl = 'http://localhost:16110';
```

**Change to (Production):**
```dart
const kDefaultApiBaseUrl = 'https://api.appydex.co';
```

**Verification:**
```bash
# Before deploying, search for localhost references:
grep -r "localhost" lib/
```

---

### 2. API Path Prefix (Backend Coordination)

**File:** `lib/core/api_client.dart`  
**Function:** `_resolveBaseUrl` (~line 140)

**Development (if backend has no /api/v1):**
```dart
static String _resolveBaseUrl(String origin) {
  final sanitized = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  return sanitized; // No prefix
}
```

**Production (standard API versioning):**
```dart
static String _resolveBaseUrl(String origin) {
  final sanitized = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  if (sanitized.endsWith('/api/v1')) return sanitized;
  return '$sanitized/api/v1';
}
```

**Verification:** Confirm with backend team the final API structure.

---

### 3. Remove/Hide Default Admin Credentials

**File:** `lib/features/auth/login_screen.dart`  
**Location:** In UI hints or default values

**Development:** Shows default credentials for convenience  
**Production:** Remove or wrap in debug check

```dart
import 'package:flutter/foundation.dart' show kDebugMode;

// In login screen:
if (kDebugMode) {
  // Show default email/password hint
  Text('Default: admin@appydex.test / ChangeMe@2025!');
}
```

---

### 4. Admin Token Configuration (If Used)

**File:** `lib/core/admin_config.dart`  
**Check:** If `AdminConfig.adminToken` is hardcoded

**Development:** May have hardcoded token for testing  
**Production:** Load from secure environment variable or remove if not needed

```dart
// BAD (Development):
static const String? adminToken = 'test-admin-token-123';

// GOOD (Production):
static const String? adminToken = String.fromEnvironment('ADMIN_TOKEN');
```

**Build command:**
```bash
flutter build web --dart-define=ADMIN_TOKEN=your_secure_token
```

---

## 🟠 HIGH PRIORITY CHANGES

### 5. Enable Error Logging (Sentry)

**File:** `lib/main.dart`  
**Add:** Sentry initialization

**Development:** Error logging optional  
**Production:** Must enable Sentry for error tracking

**Add to `pubspec.yaml`:**
```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

**Add to `main.dart`:**
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '', // Empty in dev
      );
      options.environment = kAppFlavor;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(...),
  );
}
```

**Build command:**
```bash
flutter build web --dart-define=SENTRY_DSN=https://your-sentry-dsn
```

---

### 6. Analytics Endpoint Configuration

**File:** `lib/core/analytics_client.dart`  
**Check:** Analytics endpoint URL

**Development:** May use staging analytics endpoint  
**Production:** Must use production analytics endpoint

**Pattern:**
```dart
final analyticsEndpoint = infraBaseUrl(apiBaseUrl) + '/analytics';
```

Verify `infraBaseUrl` function returns correct production URL.

---

### 7. Web Security Headers (CSP, CORS)

**Platform:** Web deployment (Nginx/Apache/Cloudflare)

**Production web server config (Nginx example):**

```nginx
server {
  # ... other config ...
  
  # Content Security Policy
  add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval';
    style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
    font-src 'self' https://fonts.gstatic.com;
    connect-src 'self' https://api.appydex.co wss://api.appydex.co;
    img-src 'self' data: https:;
  ";
  
  # Other security headers
  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-Content-Type-Options "nosniff";
  add_header Referrer-Policy "strict-origin-when-cross-origin";
}
```

**CORS:** Ensure backend allows your production domain:
```python
# Backend CORS config
ALLOWED_ORIGINS = [
    "https://admin.appydex.co",
    "https://admin.appydex.com",
]
```

---

## 🟡 MEDIUM PRIORITY CHANGES

### 8. Certificate Pinning (Desktop Apps)

**Platform:** Windows/macOS/Linux builds

**Development:** No cert pinning  
**Production:** Pin production API certificate

**File:** Create `lib/core/security/cert_pinning.dart`

```dart
import 'dart:io';

SecurityContext createSecurityContext() {
  final context = SecurityContext.defaultContext;
  
  if (kReleaseMode) {
    // Load pinned certificate
    context.setTrustedCertificatesBytes(
      // Your production cert bytes here
      productionCertificate,
    );
  }
  
  return context;
}
```

---

### 9. Feature Flags Configuration

**File:** `lib/core/config.dart` or separate feature flags file

**Development:** All features enabled  
**Production:** Control rollout with feature flags

**Pattern:**
```dart
class FeatureFlags {
  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE',
    defaultValue: false,
  );
  
  static const bool enableAnalyticsWrite = bool.fromEnvironment(
    'ENABLE_ANALYTICS_WRITE',
    defaultValue: false,
  );
}
```

---

### 10. Build Mode Checks

**Usage:** Throughout codebase where behavior differs

**Pattern:**
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  // Development-only code
  print('Debug info: $data');
}

if (kReleaseMode) {
  // Production-only code
  initializeMonitoring();
}
```

---

## 📋 PRE-DEPLOYMENT CHECKLIST

### Code Review
- [ ] Search codebase for `localhost` references
- [ ] Search for hardcoded credentials
- [ ] Search for `print()` statements (replace with logger)
- [ ] Search for `TODO` and `FIXME` comments

```bash
grep -r "localhost" lib/
grep -r "print(" lib/
grep -r "TODO\|FIXME" lib/
```

### Configuration Files
- [ ] Update `kDefaultApiBaseUrl` to production
- [ ] Verify API path prefix matches backend
- [ ] Remove/hide default admin credentials
- [ ] Configure Sentry DSN
- [ ] Set feature flags appropriately
- [ ] Update analytics endpoint

### Build & Deploy
- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all pass)
- [ ] Build with production flags:

**Web:**
```bash
flutter build web --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=SENTRY_DSN=your-dsn \
  --dart-define=ADMIN_TOKEN=your-token
```

**Windows:**
```bash
flutter build windows --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=SENTRY_DSN=your-dsn
```

**macOS:**
```bash
flutter build macos --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=SENTRY_DSN=your-dsn
```

**Linux:**
```bash
flutter build linux --release \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=SENTRY_DSN=your-dsn
```

### Security
- [ ] Enable HTTPS only (no HTTP fallback)
- [ ] Configure CSP headers on web server
- [ ] Verify CORS configuration on backend
- [ ] Test certificate pinning (desktop)
- [ ] Audit dependencies for vulnerabilities:
```bash
flutter pub outdated
```

### Testing
- [ ] Smoke test: Login → Dashboard → Logout
- [ ] Test against production API (staging environment first)
- [ ] Verify all CRUD operations work
- [ ] Test role-based access control
- [ ] Test error scenarios (network down, invalid token, etc.)

---

## 🔧 ENVIRONMENT-BASED CONFIGURATION PATTERN

**Recommended approach for managing dev/staging/prod:**

**File:** `lib/core/env.dart`

```dart
enum AppEnvironment { dev, staging, prod }

class Env {
  static const AppEnvironment current = AppEnvironment.values.byName(
    String.fromEnvironment('ENV', defaultValue: 'dev'),
  );
  
  static String get apiBaseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://localhost:16110';
      case AppEnvironment.staging:
        return 'https://staging-api.appydex.co';
      case AppEnvironment.prod:
        return 'https://api.appydex.co';
    }
  }
  
  static String? get sentryDsn {
    if (current == AppEnvironment.dev) return null;
    return const String.fromEnvironment('SENTRY_DSN');
  }
  
  static bool get enableDebugLogging => current == AppEnvironment.dev;
}
```

**Build commands:**
```bash
# Development
flutter run -d chrome --dart-define=ENV=dev

# Staging
flutter build web --dart-define=ENV=staging --dart-define=SENTRY_DSN=...

# Production
flutter build web --dart-define=ENV=prod --dart-define=SENTRY_DSN=...
```

---

## 📞 COORDINATION WITH BACKEND TEAM

### Before Production Deploy, Verify:

1. **API Endpoint Structure**
   - Does production use `/api/v1` prefix?
   - Are admin endpoints under `/admin` or `/api/v1/admin`?

2. **CORS Configuration**
   - Is admin frontend domain whitelisted?
   - Are preflight OPTIONS requests handled?

3. **Authentication**
   - Token expiry times (access: 15min, refresh: 30 days)
   - Refresh token rotation enabled?
   - Admin token requirement (if any)?

4. **Rate Limiting**
   - Are admin endpoints rate-limited differently?
   - What are the limits per endpoint?

5. **Idempotency**
   - Does backend enforce `Idempotency-Key` header?
   - How long are idempotency keys cached?

---

## 📊 POST-DEPLOYMENT MONITORING

### Key Metrics to Watch

1. **Error Rates** (Sentry)
   - Login failures
   - API errors (4xx, 5xx)
   - Client-side exceptions

2. **Performance**
   - Page load times
   - API response times
   - Large payload warnings

3. **User Actions**
   - Successful logins per day
   - CRUD operations per admin
   - Failed permission checks (potential security issue)

---

## 🚨 ROLLBACK PROCEDURE

If issues occur in production:

1. **Immediate:** Revert web deployment to previous build
2. **Backend:** Roll back API changes if breaking
3. **Monitor:** Check Sentry for error spikes
4. **Notify:** Alert users if service is degraded
5. **Debug:** Use trace IDs to track down issues

---

## ✅ FINAL VERIFICATION SCRIPT

```bash
#!/bin/bash
# production_check.sh

echo "=== Production Readiness Check ==="

echo "Checking for localhost references..."
if grep -r "localhost" lib/ | grep -v "// "; then
  echo "❌ Found localhost references!"
  exit 1
else
  echo "✅ No localhost references"
fi

echo "Checking for hardcoded credentials..."
if grep -r -i "password.*=" lib/ | grep -v "TextField\|FormField\|//"; then
  echo "⚠️  Review potential hardcoded passwords"
else
  echo "✅ No obvious hardcoded credentials"
fi

echo "Checking for debug print statements..."
if grep -r "print(" lib/ | grep -v "//"; then
  echo "⚠️  Found print() statements - consider using logger"
else
  echo "✅ No print() statements"
fi

echo "Running flutter analyze..."
if flutter analyze; then
  echo "✅ No analysis errors"
else
  echo "❌ Analysis errors found!"
  exit 1
fi

echo "Running tests..."
if flutter test; then
  echo "✅ Tests passed"
else
  echo "❌ Tests failed!"
  exit 1
fi

echo ""
echo "=== Manual Checklist ==="
echo "[ ] Updated kDefaultApiBaseUrl to production"
echo "[ ] Configured Sentry DSN"
echo "[ ] Removed/hid default credentials"
echo "[ ] Backend CORS configured"
echo "[ ] Web CSP headers configured"
echo "[ ] Tested against staging environment"
echo "[ ] Smoke tests passed"
echo ""
echo "Ready for production deployment!"
```

---

**Save this document and review before every production deployment.**

**Last Updated:** November 3, 2025
