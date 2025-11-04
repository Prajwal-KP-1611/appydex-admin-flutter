## Quick Start

### Running the Admin Panel

**Web (recommended for admin):**
```bash
flutter run -d chrome --web-port=46633 --web-hostname=localhost
```
The app will be available at `http://localhost:46633`

**VS Code:** Press F5 to launch with the configured web port (46633)

**Mobile/Desktop:**
```bash
flutter run
```

---

## Admin Foundations

- **Admin token**: set once at runtime via `AdminConfig.adminToken = '<ADMIN_TOKEN>'` (or wire a secure storage fetch). All `requestAdmin` calls automatically attach `X-Admin-Token`.
- **Mock fallback**: enable QA mode with `mockModeProvider` (e.g. via diagnostics) to render sample vendors/subscriptions/audit rows when admin endpoints are missing.
- **Repositories**: use `VendorRepository`, `SubscriptionRepository`, and `AuditRepository` for paginated admin data; each throws `AdminEndpointMissing` to signal missing backend routes.
- **CSV export**: call `toCsv` from `lib/core/export_util.dart` with the current filter rows to generate client-side exports.
- **Analytics**: `AnalyticsClient` fetches Prometheus metrics from `/metrics` (falling back to `/api/v1/admin/metrics` when available).
- **Tests**: run `flutter test` to cover ApiClient admin plumbing, export util, and repository fallbacks.
- **Screens**: dashboard, vendors, subscriptions, and audit logs all live under the admin shell; use the left navigation to switch views.
- **Mock toggle in UI**: when an admin endpoint is missing you'll see a card with "Use mock data" - toggling it pulls data from `MockAdminFallback` so flows stay testable.
- **Trace-aware snackbars**: all success/error operations surface the latest `x-trace-id`; copy it straight from the snackbar for backend follow-up.

### Sample cURL commands

```bash
BASE=https://api.appydex.co

# List vendors (admin)
curl -X GET "$BASE/api/v1/admin/vendors?page=1&page_size=20" \
  -H "X-Admin-Token: <ADMIN_TOKEN>"

# Vendor detail
curl -X GET "$BASE/api/v1/admin/vendors/123" \
  -H "X-Admin-Token: <ADMIN_TOKEN>"

# Verify vendor via PATCH
curl -X PATCH "$BASE/api/v1/admin/vendors/123" \
  -H "X-Admin-Token: <ADMIN_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"is_verified":true,"notes":"Verified via UI"}'

# List subscriptions
curl -X GET "$BASE/api/v1/admin/subscriptions?page=1&page_size=20" \
  -H "X-Admin-Token: <ADMIN_TOKEN>"

# Activate subscription
curl -X POST "$BASE/api/v1/subscriptions/42/activate" \
  -H "X-Admin-Token: <ADMIN_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"paid_months":3}'
```

## Troubleshooting

- Dio Web: GET/HEAD requests automatically disable sendTimeout to avoid browser fetch errors; payload requests continue to respect the configured timeout.
- Diagnostics call `/healthz` at the root of the API host (not under `/api/v1`); a 404 usually means the infra endpoint is missing.
- The `last-otp` endpoint is not implemented by default--use backend tooling if you need OTP visibility.
