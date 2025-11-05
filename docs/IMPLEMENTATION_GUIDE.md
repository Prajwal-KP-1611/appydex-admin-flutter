# Implementation Guide: Remaining Critical Features

This document provides code snippets and implementation guidance for the remaining critical features needed to match the specification.

## 🚀 IMMEDIATE ACTIONS REQUIRED

### 1. Update `pubspec.yaml` - Add Missing Dependencies

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Additional required packages
  intl: ^0.19.0
  collection: ^1.18.0
  
  # For file uploads (future use)
  file_picker: ^6.1.1
  
  # For charts in analytics (future use)
  fl_chart: ^0.66.0
  
  # For CSV exports (future use)
  csv: ^6.0.0
```

**Run:** `flutter pub get`

---

### 2. Update Main Routing to Include Change Password Flow

**File:** `lib/main.dart`

Add in `onGenerateRoute`:

```dart
case '/change-password':
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => const ChangePasswordScreen(),
  );
```

And update the login success handler to check `must_change_password` flag.

---

### 3. Update Auth Service to Handle Password Change Requirement

**File:** `lib/core/auth/auth_service.dart`

After successful login, check the `must_change_password` field from backend response and update the session model.

---

## 📦 NEW SCREENS TO CREATE

### Admin Management Screen (High Priority)

**File:** `lib/features/admins/admins_list_screen.dart`

This screen displays all admin users with:
- DataTable with pagination
- Search by email/name
- Filter by role and status
- Create/Edit/Delete actions
- Toggle active/inactive
- Force password reset

**Key Features:**
- Server-side pagination
- Role-based access (only super_admin can CRUD admins)
- Bulk actions (future)
- Export to CSV (future)

---

### Services Management Screen

**File:** `lib/features/services/services_list_screen.dart`

- List all services with categories
- Create/Edit service
- Toggle visibility
- Assign to categories

---

### Subscription Plans Management

**File:** `lib/features/plans/plans_list_screen.dart`

- List subscription plans
- Create/Edit plans with pricing
- Configure free trial days
- Activate/Deactivate plans

---

### Payments & Refunds Screen

**File:** `lib/features/payments/payments_list_screen.dart`

- List payments with filters
- View payment details
- Process refunds
- Download invoices (PDF)

---

### Enhanced Dashboard

**File:** `lib/features/dashboard/dashboard_screen.dart` (UPDATE)

Add:
- KPI cards (vendors, users, MRR, daily signups)
- Recent audit logs feed
- Quick action buttons
- Alert notifications

---

### Analytics Dashboard

**File:** `lib/features/analytics/analytics_screen.dart` (NEW)

- Charts: vendor growth, revenue trends, top searches
- Date range picker
- Export to CSV
- Real-time metrics from Mongo

---

## 🔧 CONFIGURATION CHECKLIST

### Before Testing with Local Backend

1. ✅ Update `lib/core/config.dart` - API URL to `http://localhost:16110`
2. ⏳ Verify backend endpoints exist (check OpenAPI spec)
3. ⏳ Test auth flow: `/auth/admin/login` or `/admin/auth/login`
4. ⏳ Verify refresh token endpoint: `/auth/refresh`
5. ⏳ Check admin endpoints prefix: `/admin/*` or `/api/v1/admin/*`

### Check OpenAPI Spec

```bash
curl http://localhost:16110/openapi/v1.json | jq '.paths | keys'
```

Look for:
- Auth endpoints
- Admin user management endpoints
- Vendor management endpoints
- Subscription & payment endpoints

### Update API Client if Needed

If backend does NOT use `/api/v1` prefix:

**File:** `lib/core/api_client.dart`

```dart
static String _resolveBaseUrl(String origin) {
  final sanitized = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  // Return as-is for local dev (no /api/v1 prefix)
  return sanitized;
}
```

---

## ⚠️ PRODUCTION CHANGE POINTS SUMMARY

### Point 1: API Base URL
**File:** `lib/core/config.dart`
**Line:** ~6
**Dev:** `const kDefaultApiBaseUrl = 'http://localhost:16110';`
**Prod:** `const kDefaultApiBaseUrl = 'https://api.appydex.co';`

### Point 2: API Path Prefix
**File:** `lib/core/api_client.dart`
**Function:** `_resolveBaseUrl`
**Dev:** May not append `/api/v1`
**Prod:** Ensure it matches production API structure

### Point 3: Default Admin Credentials Display
**File:** `lib/features/auth/login_screen.dart`
**Dev:** Shows default credentials
**Prod:** Wrap in `if (kDebugMode) { ... }`

### Point 4: Error Logging
**Prod:** Integrate Sentry:
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
    options.environment = kAppFlavor;
  },
);
```

### Point 5: Certificate Pinning (Desktop)
**Prod:** Implement TLS certificate pinning for API calls

### Point 6: Web CSP Headers
**Prod:** Configure web server (Nginx/Apache) with proper CSP

---

## 🧪 TESTING GUIDE

### Manual Testing Checklist

#### Auth Flow
- [ ] Login with correct credentials
- [ ] Login with wrong credentials (see error)
- [ ] Forced password change flow (if `must_change_password: true`)
- [ ] Logout
- [ ] Session restoration on app reload

#### Admin Management
- [ ] List all admins
- [ ] Search admins by email
- [ ] Filter by role
- [ ] Create new admin
- [ ] Edit existing admin
- [ ] Deactivate admin
- [ ] Delete admin
- [ ] Force password reset

#### Vendors
- [ ] List vendors
- [ ] View vendor details
- [ ] Approve vendor (with idempotency)
- [ ] Reject vendor
- [ ] Search and filter

#### RBAC
- [ ] Login as different roles
- [ ] Verify UI shows/hides based on permissions
- [ ] Attempt unauthorized action (should get 403)

---

## 📊 IMPLEMENTATION PROGRESS TRACKER

### Phase A - Core Admin MVP (Week 1)
- [x] Auth system (login, refresh, logout)
- [x] Theme & design system
- [x] RBAC model
- [x] Admin layout with sidebar
- [x] Idempotency utility
- [x] Toast notification service
- [x] Form validators
- [x] Change password screen
- [x] Admin user model
- [x] Admin user repository
- [ ] Admin users CRUD screen ⏳ **IN PROGRESS**
- [ ] Services CRUD screen
- [ ] Vendor approval workflow completion

### Phase B - Billing & Subscriptions (Week 2)
- [ ] Subscription plans CRUD
- [ ] Payments list
- [ ] Refund processing
- [ ] Invoice downloads

### Phase C - Reviews & Users (Week 2-3)
- [ ] Reviews moderation
- [ ] User management
- [ ] Referral campaigns

### Phase D - Analytics (Week 3-4)
- [ ] Enhanced dashboard with KPIs
- [ ] Analytics charts
- [ ] CSV exports

### Phase E - Desktop & Offline (Week 4-5)
- [ ] Drift database setup
- [ ] Offline sync queue
- [ ] Desktop builds
- [ ] Auto-update mechanism

### Phase F - Polish (Week 5-6)
- [ ] Testing all modules
- [ ] Performance optimization
- [ ] Security audit
- [ ] Production deployment prep

---

## 🔗 API ENDPOINT MAPPING

### Verify these exist in your backend:

```bash
# Check endpoints
curl http://localhost:16110/openapi/v1.json | jq '.paths | keys | .[]' | grep -E '(auth|admin)'
```

**Expected endpoints:**

**Auth:**
- `POST /auth/admin/login` or `/admin/auth/login`
- `POST /auth/refresh`
- `POST /auth/change-password`
- `GET /admin/me`

**Admin Users:**
- `GET /admin/users`
- `POST /admin/users`
- `GET /admin/users/{id}`
- `PATCH /admin/users/{id}`
- `DELETE /admin/users/{id}`
- `POST /admin/users/{id}/force-password-reset`

**Vendors:**
- `GET /admin/vendors`
- `GET /admin/vendors/{id}`
- `POST /admin/vendors/{id}/verify`
- `POST /admin/vendors/{id}/reject`
- `GET /admin/vendors/{id}/documents`

**Services:**
- `GET /admin/services`
- `POST /admin/services`
- `PATCH /admin/services/{id}`
- `DELETE /admin/services/{id}`

**Subscriptions:**
- `GET /admin/subscriptions/plans`
- `POST /admin/subscriptions/plans`
- `PATCH /admin/subscriptions/plans/{id}`

**Payments:**
- `GET /admin/payments`
- `POST /admin/payments/{id}/refund`

**Analytics:**
- `GET /admin/dashboard/summary`
- `GET /admin/analytics/top_searches`
- `POST /admin/analytics/export`

**System:**
- `GET /admin/system/health`
- `POST /admin/system/backup`

---

## 🚨 KNOWN ISSUES & WORKAROUNDS

### Issue 1: DioException vs DioError
**Problem:** Dio v5 uses `DioException`, but some older code may use `DioError`.
**Fix:** Use `DioError` for Dio 5.7.0 (your current version).

### Issue 2: Empty Admin User Model
**Status:** ✅ Fixed - Model now complete with all fields

### Issue 3: Missing Toast Notifications
**Status:** ✅ Fixed - `ToastService` created

### Issue 4: No Idempotency Helper
**Status:** ✅ Fixed - `idempotency.dart` utility created

---

## 📝 NEXT IMMEDIATE STEPS

1. **Run `flutter pub get`** after adding dependencies
2. **Check backend OpenAPI spec** and verify endpoints
3. **Test auth flow** against local backend
4. **Implement Admin Users CRUD screen** (highest priority)
5. **Test RBAC** - ensure super_admin can create admins
6. **Add `/change-password` route** to main.dart
7. **Test forced password change flow**

---

## 💡 TIPS FOR IMPLEMENTATION

### Use Existing Patterns
- Follow the structure in `vendors_list_screen.dart` for list screens
- Use `AdminLayout` for all admin screens (not old `AdminScaffold`)
- Reuse `DataTableSimple` widget for tables
- Use `FilterRow` widget for search/filters

### Error Handling
- Always wrap API calls in try-catch
- Use `ToastService` for user feedback
- Log errors with trace IDs
- Show user-friendly messages

### Idempotency
- Use `idempotentOptions()` for all POST/PATCH/DELETE
- Backend should deduplicate using `Idempotency-Key` header

### Pagination
- Default page size: 25
- Max page size: 100
- Always show total count

### Loading States
- Show `CircularProgressIndicator` while loading
- Use `AsyncValue` from Riverpod for automatic loading/error states
- Provide skeleton loaders for better UX (future enhancement)

---

## 📚 REFERENCE LINKS

- **Flutter Docs:** https://docs.flutter.dev
- **Riverpod Docs:** https://riverpod.dev
- **Dio Docs:** https://pub.dev/packages/dio
- **Material 3 Design:** https://m3.material.io

---

**For questions or clarification on implementation, refer to the main GAP_ANALYSIS.md document.**
