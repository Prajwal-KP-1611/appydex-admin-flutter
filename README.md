## Admin Foundations

- **Admin token**: set once at runtime via `AdminConfig.adminToken = '<ADMIN_TOKEN>'` (or wire a secure storage fetch). All `requestAdmin` calls automatically attach `X-Admin-Token`.
- **Mock fallback**: enable QA mode with `mockModeProvider` (e.g. via diagnostics) to render sample vendors/subscriptions/audit rows when admin endpoints are missing.
- **Repositories**: use `VendorRepository`, `SubscriptionRepository`, and `AuditRepository` for paginated admin data; each throws `AdminEndpointMissing` to signal missing backend routes.
- **CSV export**: call `toCsv` from `lib/core/export_util.dart` with the current filter rows to generate client-side exports.
- **Analytics**: `AnalyticsClient` fetches Prometheus metrics from `/metrics` (falling back to `/api/v1/admin/metrics` when available).
- **Tests**: run `flutter test` to cover ApiClient admin plumbing, export util, and repository fallbacks.

## Troubleshooting

- Dio Web: GET/HEAD requests automatically disable sendTimeout to avoid browser fetch errors; payload requests continue to respect the configured timeout.
- Diagnostics call `/healthz` at the root of the API host (not under `/api/v1`); a 404 usually means the infra endpoint is missing.
- The `last-otp` endpoint is not implemented by default—use backend tooling if you need OTP visibility.
