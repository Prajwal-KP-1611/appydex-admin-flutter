# AppyDex Admin Frontend - Gap Analysis & Implementation Plan

**Date:** November 3, 2025  
**Backend URL (Local):** http://localhost:16110  
**OpenAPI Spec:** http://localhost:16110/openapi/v1.json

---

## Executive Summary

Your admin frontend has **solid foundation (15% complete)** but needs significant work to match the production-ready specification. This document identifies gaps, provides implementation priorities, and marks production configuration points.

### What You Have ✅
- Complete auth system (JWT + refresh)
- RBAC model (5 roles with permission matrix)
- Theme matching brand spec
- API client with interceptors, idempotency, retry logic
- Basic screens: Login, Dashboard (skeleton), Vendors list, Audit logs

### Critical Gaps ❌
- **No offline/desktop support** (Drift, Hive not added)
- **Missing 70% of CRUD screens** (admins, services, payments, analytics, etc.)
- **No forced password change flow**
- **No bulk actions or advanced filtering**
- **No file upload** (presigned URLs for documents)
- **No analytics dashboards or charts**
- **No job status polling** (exports, backups)
- **No idempotency key generation in UI**
- **No desktop builds configured**
- **API base URL hardcoded** (needs local override for dev)

---

## Part 1: Configuration Changes for Local Development

### 🔧 CHANGE #1: Update Default API Base URL

**File:** `lib/core/config.dart`

**Current:**
```dart
const kDefaultApiBaseUrl = 'https://api.appydex.co';
```

**Change to:**
```dart
// PRODUCTION: Set this to 'https://api.appydex.co' before release
const kDefaultApiBaseUrl = 'http://localhost:16110';
```

**⚠️ PRODUCTION CHANGE POINT:**  
Before deploying to production, revert this to `https://api.appydex.co` and rebuild.

---

### 🔧 CHANGE #2: Update API Client Base URL Resolution

**File:** `lib/core/api_client.dart`

**Current:**
```dart
static String _resolveBaseUrl(String origin) {
  final sanitized = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  if (sanitized.endsWith('/api/v1')) return sanitized;
  return '$sanitized/api/v1';
}
```

**Issue:** Local backend uses `/openapi/v1.json` but API might not have `/api/v1` prefix.

**Action:** Check your local backend routes at `http://localhost:16110/openapi/v1.json` and verify:
- Are admin endpoints under `/api/v1/admin/*` or `/admin/*`?
- Update `_resolveBaseUrl` accordingly.

**Suggested Fix (if backend uses no `/api/v1` prefix):**
```dart
static String _resolveBaseUrl(String origin) {
  final sanitized = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  // For local dev, backend might not have /api/v1 prefix
  // PRODUCTION: Ensure backend uses /api/v1
  return sanitized;
}
```

**⚠️ PRODUCTION CHANGE POINT:**  
Coordinate with backend team on final URL structure.

---

### 🔧 CHANGE #3: Admin Login Endpoint

**File:** `lib/core/auth/auth_service.dart`

**Current:**
```dart
final response = await _apiClient.dio.post<Map<String, dynamic>>(
  '/auth/admin/login',
  data: {'email': email, 'password': password},
  options: Options(extra: const {'skipAuth': true}),
);
```

**Verify:** Does your local backend have `/auth/admin/login` or just `/auth/login`?

**Action:** Check OpenAPI spec and update if needed. If it's `/admin/auth/login`, change to:
```dart
'/admin/auth/login'
```

**⚠️ PRODUCTION CHANGE POINT:**  
Document final auth endpoint in deployment guide.

---

### 🔧 CHANGE #4: Default Admin Credentials

**File:** `lib/features/auth/login_screen.dart` (currently shows `root@appydex.com / Admin@123`)

**Check:** Does your seeded admin in backend match?

**Expected from spec:**
- Email: `admin@appydex.test`
- Password: `ChangeMe@2025!`
- Flag: `must_change_password: true`

**Action:** Update login screen hint text and add forced password change flow (see implementation below).

---

## Part 2: Missing Dependencies (Add to pubspec.yaml)

**File:** `pubspec.yaml`

Add these dependencies:

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Desktop & Offline Support
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3
  
  # Simple key-value storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # File uploads
  file_picker: ^6.1.1
  http_parser: ^4.0.2
  
  # Charts & Analytics
  fl_chart: ^0.66.0
  
  # CSV Export
  csv: ^6.0.0
  
  # Date handling
  intl: ^0.19.0
  
  # Utilities
  collection: ^1.18.0

dev_dependencies:
  # ... existing dev_dependencies ...
  
  # Drift code generation
  drift_dev: ^2.14.1
  build_runner: ^2.4.7
```

**⚠️ PRODUCTION CHANGE POINT:**  
No changes needed for production.

---

## Part 3: Critical Missing Features (Prioritized)

### Priority 1: Forced Password Change Flow ⏰ 2 hours

**Status:** ❌ Missing  
**Why Critical:** Spec requires default admin must change password on first login.

**Implementation:**

1. Update `AdminSession` model to include `mustChangePassword` field
2. Add password change screen
3. Add redirect logic after login

**Files to Create/Modify:**

`lib/features/auth/change_password_screen.dart` - NEW  
`lib/models/admin_role.dart` - UPDATE  
`lib/core/auth/auth_service.dart` - UPDATE

---

### Priority 2: Idempotency Key Generation ⏰ 30 minutes

**Status:** ❌ Missing  
**Why Critical:** Spec requires all mutations use `Idempotency-Key` header.

**Current:** API client supports it via `extra['idempotencyKey']`, but no UI helper.

**Implementation:**

Create utility function to generate and attach keys automatically:

`lib/core/utils/idempotency.dart` - NEW

```dart
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generate idempotency key for mutation requests
String generateIdempotencyKey() => _uuid.v4();

/// Extension on Dio Options to easily add idempotency
extension IdempotentOptions on Map<String, dynamic> {
  Map<String, dynamic> withIdempotency() {
    return {...this, 'idempotencyKey': generateIdempotencyKey()};
  }
}
```

**Usage in repositories:**
```dart
await apiClient.requestAdmin(
  '/admin/vendors/$id/verify',
  method: 'POST',
  options: Options(extra: {}.withIdempotency()),
);
```

---

### Priority 3: Admin Users CRUD ⏰ 8 hours

**Status:** ❌ Missing  
**Why Critical:** Phase A deliverable, needed for multi-admin setup.

**Screens:**
1. Admin list (DataTable with pagination)
2. Create admin modal
3. Edit admin modal
4. Role assignment UI

**Backend Endpoints Required:**
- `GET /admin/users` (or `/admin/admins`)
- `POST /admin/users`
- `PATCH /admin/users/{id}`
- `DELETE /admin/users/{id}`
- `GET /admin/roles` (list available roles/permissions)

**Files to Create:**

`lib/features/admins/admins_list_screen.dart` - NEW  
`lib/features/admins/admin_form_dialog.dart` - NEW  
`lib/repositories/admin_user_repo.dart` - UPDATE (already exists but empty)  
`lib/models/admin_user.dart` - UPDATE (currently empty)

---

### Priority 4: Vendor Approval Workflow ⏰ 6 hours

**Status:** 🟡 Partial (list exists, approval missing)

**Missing:**
- Approve/Reject buttons with confirmation
- Bulk approve
- Document viewer (KYC docs from S3)
- Idempotency on approve action

**Backend Endpoints Required:**
- `POST /admin/vendors/{id}/verify`
- `POST /admin/vendors/bulk_verify`
- `GET /admin/vendors/{id}/documents`

**Files to Modify:**

`lib/features/vendors/vendor_detail_screen.dart` - UPDATE  
`lib/features/vendors/vendors_list_screen.dart` - UPDATE (add bulk actions)  
`lib/repositories/vendor_repo.dart` - UPDATE

---

### Priority 5: Services CRUD ⏰ 6 hours

**Status:** ❌ Missing  
**Why Critical:** Phase A deliverable.

**Screens:**
1. Services list
2. Create/Edit service form
3. Category tree picker

**Backend Endpoints Required:**
- `GET /admin/services`
- `POST /admin/services`
- `PATCH /admin/services/{id}`
- `DELETE /admin/services/{id}`

**Files to Create:**

`lib/features/services/services_list_screen.dart` - NEW  
`lib/features/services/service_form_dialog.dart` - NEW  
`lib/repositories/service_repo.dart` - NEW  
`lib/models/service.dart` - NEW

---

### Priority 6: Subscription Plans Management ⏰ 8 hours

**Status:** 🟡 Partial (subscriptions screen exists)

**Missing:**
- Plan CRUD
- Pricing configuration
- Free trial days config
- Activate/Deactivate plan

**Backend Endpoints Required:**
- `GET /admin/subscriptions/plans`
- `POST /admin/subscriptions/plans`
- `PATCH /admin/subscriptions/plans/{id}`
- `POST /admin/subscriptions/plans/{id}/activate`

**Files to Create:**

`lib/features/plans/plans_list_screen.dart` - NEW  
`lib/features/plans/plan_form_dialog.dart` - NEW  
`lib/repositories/subscription_plan_repo.dart` - NEW  
`lib/models/subscription_plan.dart` - NEW

---

### Priority 7: Payments & Refunds ⏰ 6 hours

**Status:** ❌ Missing

**Screens:**
1. Payments list (filters by date, vendor, status)
2. Payment detail view
3. Refund dialog

**Backend Endpoints Required:**
- `GET /admin/payments`
- `POST /admin/payments/{id}/refund`
- `GET /admin/invoices/{id}` (PDF download)

**Files to Create:**

`lib/features/payments/payments_list_screen.dart` - NEW  
`lib/features/payments/payment_detail_screen.dart` - NEW  
`lib/features/payments/refund_dialog.dart` - NEW  
`lib/repositories/payment_repo.dart` - NEW  
`lib/models/payment.dart` - NEW

---

### Priority 8: Analytics Dashboard ⏰ 12 hours

**Status:** ❌ Missing  
**Why Critical:** Phase D deliverable.

**Screens:**
1. Enhanced dashboard with KPI cards
2. Charts (vendor growth, revenue, searches)
3. Date range picker
4. Export to CSV

**Backend Endpoints Required:**
- `GET /admin/dashboard/summary`
- `GET /admin/analytics/top_searches`
- `GET /admin/analytics/ctr`
- `POST /admin/analytics/export` (job-based)

**Files to Create:**

`lib/features/dashboard/widgets/kpi_card.dart` - NEW  
`lib/features/dashboard/widgets/chart_widget.dart` - NEW  
`lib/features/analytics/analytics_screen.dart` - NEW  
`lib/repositories/analytics_repo.dart` - NEW

**Dependencies:** `fl_chart` package

---

### Priority 9: Reviews Moderation ⏰ 4 hours

**Status:** 🟡 Partial (reviews screen exists)

**Missing:**
- Publish/Unpublish action
- Flag review with reason
- Moderation notes

**Backend Endpoints Required:**
- `GET /admin/reviews`
- `PATCH /admin/reviews/{id}` (status update)
- `POST /admin/reviews/{id}/flag`

**Files to Modify:**

`lib/features/reviews/reviews_screen.dart` - UPDATE  
`lib/repositories/review_repo.dart` - UPDATE

---

### Priority 10: Desktop Build Configuration ⏰ 4 hours

**Status:** ❌ Missing

**Requirements:**
- Configure Windows/macOS/Linux targets
- Drift database for offline queue
- Secure token storage via OS keychain
- Auto-update mechanism (basic)

**Actions:**
1. Enable desktop platforms: `flutter config --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop`
2. Create Drift database schema
3. Create offline sync queue
4. Test desktop builds

**Files to Create:**

`lib/core/database/app_database.dart` - NEW (Drift schema)  
`lib/core/database/sync_queue.dart` - NEW  
`lib/core/storage/secure_desktop_storage.dart` - NEW

---

## Part 4: Production Configuration Points

### 📍 Point 1: API Base URL
**File:** `lib/core/config.dart`  
**Line:** `const kDefaultApiBaseUrl = 'http://localhost:16110';`  
**Production Value:** `'https://api.appydex.co'`

---

### 📍 Point 2: Admin Token (if using)
**File:** `lib/core/admin_config.dart`  
**Check:** Is `AdminConfig.adminToken` used? If yes, ensure it's env-based.  
**Production:** Load from environment or secure vault, never hardcode.

---

### 📍 Point 3: Default Admin Credentials Display
**File:** `lib/features/auth/login_screen.dart`  
**Current:** Shows default credentials  
**Production:** Remove hint text or show only for non-prod builds:

```dart
if (kDebugMode) {
  // Show default creds
}
```

---

### 📍 Point 4: Error Logging & Sentry
**Current:** Not integrated  
**Production:** Add Sentry SDK and capture all `AppHttpException` errors.

**Add to pubspec:**
```yaml
sentry_flutter: ^7.14.0
```

**Init in main.dart:**
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
    options.environment = kAppFlavor;
  },
);
```

---

### 📍 Point 5: Analytics Telemetry
**File:** `lib/core/analytics_client.dart` (already exists)  
**Production:** Ensure it sends to production analytics endpoint, not staging.

---

### 📍 Point 6: CORS & CSP for Web Deployment
**File:** `web/index.html`  
**Production:** Add Content Security Policy headers via server config (Nginx/Cloudflare).

---

### 📍 Point 7: Certificate Pinning (Optional, Desktop)
**If implementing:** Use `dart:io` `SecurityContext` for TLS pinning.  
**Production:** Pin production API certificate.

---

## Part 5: Testing Checklist

### Unit Tests (Target: 50% coverage)
- [ ] Auth service login/logout/refresh
- [ ] RBAC permission checks
- [ ] API client interceptor logic
- [ ] Idempotency key generation
- [ ] Model serialization (toJson/fromJson)

### Integration Tests
- [ ] Login flow → Dashboard
- [ ] Vendor approve action with idempotency
- [ ] Admin CRUD operations
- [ ] Offline queue sync (desktop)

### E2E Tests (Selenium/Flutter Driver)
- [ ] Full login → approve vendor → logout flow
- [ ] Role switching
- [ ] Forced password change
- [ ] CSV export download

---

## Part 6: Implementation Timeline

### Week 1: Critical Path (Phase A Completion)
- Day 1-2: Fix API config for local backend, add missing deps
- Day 3: Implement forced password change flow
- Day 4-5: Admin Users CRUD (highest priority)
- Weekend: Testing & bug fixes

### Week 2: Core CRUD Operations
- Day 1-2: Services CRUD
- Day 3-4: Vendor approval workflow completion
- Day 5: Subscription Plans CRUD

### Week 3: Billing & Reviews
- Day 1-2: Payments & Refunds
- Day 3: Reviews moderation completion
- Day 4-5: Enhanced Dashboard with charts

### Week 4: Desktop & Offline
- Day 1-2: Drift database setup
- Day 3: Offline sync queue
- Day 4-5: Desktop builds & testing

### Week 5: Analytics & Reports
- Day 1-3: Analytics dashboards
- Day 4-5: Report generation & CSV exports

### Week 6: Polish & Production Prep
- Day 1-2: Testing across all modules
- Day 3: Production config updates
- Day 4: Deployment & smoke tests
- Day 5: Documentation & handoff

---

## Part 7: Quick Start Commands

### Run with local backend:
```bash
# Ensure backend is running at http://localhost:16110
flutter run -d chrome --dart-define=APP_FLAVOR=dev
```

### Check OpenAPI spec:
```bash
curl http://localhost:16110/openapi/v1.json | jq
```

### Add missing dependencies:
```bash
flutter pub add drift sqlite3_flutter_libs path_provider hive hive_flutter fl_chart csv file_picker intl
flutter pub add --dev drift_dev build_runner
```

### Enable desktop:
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter create . --platforms=windows,macos,linux
```

### Build for production web:
```bash
# Update kDefaultApiBaseUrl first!
flutter build web --release --dart-define=APP_FLAVOR=prod
```

---

## Part 8: File-by-File Implementation Priority

### Immediate (This Week)
1. ✅ `lib/core/config.dart` - Update API URL
2. ✅ `lib/core/utils/idempotency.dart` - Create utility
3. ✅ `lib/features/auth/change_password_screen.dart` - Create
4. ✅ `lib/models/admin_user.dart` - Complete model
5. ✅ `lib/features/admins/admins_list_screen.dart` - Create
6. ✅ `lib/repositories/admin_user_repo.dart` - Implement

### Next Sprint
7. ⏳ `lib/features/services/services_list_screen.dart`
8. ⏳ `lib/features/plans/plans_list_screen.dart`
9. ⏳ `lib/features/payments/payments_list_screen.dart`
10. ⏳ `lib/features/vendors/vendor_detail_screen.dart` - Enhance

### Following Sprint
11. ⏳ `lib/features/dashboard/dashboard_screen.dart` - Enhance with charts
12. ⏳ `lib/features/analytics/analytics_screen.dart` - Create
13. ⏳ `lib/core/database/app_database.dart` - Drift setup

---

## Part 9: Backend Coordination Points

### Verify These Endpoints Exist in Your Backend:

Check `http://localhost:16110/openapi/v1.json` for:

**Auth:**
- [ ] `POST /auth/admin/login` or `/admin/auth/login`
- [ ] `POST /auth/refresh`
- [ ] `POST /auth/change-password`

**Admins:**
- [ ] `GET /admin/users` or `/admin/admins`
- [ ] `POST /admin/users`
- [ ] `PATCH /admin/users/{id}`

**Vendors:**
- [ ] `GET /admin/vendors`
- [ ] `POST /admin/vendors/{id}/verify`
- [ ] `GET /admin/vendors/{id}/documents`

**Services:**
- [ ] `GET /admin/services`
- [ ] `POST /admin/services`

**Subscriptions:**
- [ ] `GET /admin/subscriptions/plans`
- [ ] `POST /admin/subscriptions/plans`

**Payments:**
- [ ] `GET /admin/payments`
- [ ] `POST /admin/payments/{id}/refund`

**Analytics:**
- [ ] `GET /admin/dashboard/summary`
- [ ] `GET /admin/analytics/top_searches`

**System:**
- [ ] `GET /admin/system/health`
- [ ] `POST /admin/system/backup`

**If missing, coordinate with backend team to add before FE implementation.**

---

## Part 10: Current Code Quality Assessment

### Strengths ✅
- Clean separation of concerns (features/core/models)
- Comprehensive error handling in API client
- Good use of Riverpod for state management
- Theme tokens match spec exactly
- Trace ID propagation for debugging

### Technical Debt ⚠️
- Empty model files (`admin_user.dart`)
- Duplicate layout components (old `AdminScaffold` vs new `AdminLayout`)
- No loading states/skeletons
- No toast notification system
- No bulk action framework
- Missing data table component (should add Syncfusion or custom)

### Security Concerns 🔒
- No certificate pinning
- No rate limiting on client side
- No input sanitization utilities
- Default credentials shown in UI (remove for prod)

---

## Summary: Your Next Actions

### Today:
1. ✅ Update `lib/core/config.dart` API URL to `http://localhost:16110`
2. ✅ Check OpenAPI spec and verify endpoint paths
3. ✅ Add missing dependencies to `pubspec.yaml`
4. ✅ Run `flutter pub get`

### This Week:
5. ✅ Implement forced password change flow
6. ✅ Complete Admin Users CRUD
7. ✅ Add idempotency utility
8. ✅ Test against local backend

### Next 2 Weeks:
9. ⏳ Complete Services, Plans, Payments CRUD
10. ⏳ Enhance Dashboard with charts
11. ⏳ Vendor approval workflow

### Month-End Goal:
- All Phase A-C features complete (70% of spec)
- Desktop builds working
- Ready for staging deployment

---

**Questions? Check the OpenAPI spec first, then coordinate with backend team on missing endpoints.**
