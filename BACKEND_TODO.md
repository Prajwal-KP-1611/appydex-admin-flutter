# Backend TODO — Admin Control Plane Endpoints

The frontend foundations expect the following admin endpoints. Please add them (or confirm they already exist) so that future UI screens can rely on first-class API support.

## Vendors

### `GET /api/v1/admin/vendors`
- **Purpose**: Paginated vendor directory for admins.
- **Query params**: `query`, `page`, `page_size`, `status`, `plan_code`, `verified`.
- **Response**: `{ "items": [VendorAdmin], "total": int, "page": int, "page_size": int }`
- **Suggested OpenAPI snippet**:
```yaml
  /api/v1/admin/vendors:
    get:
      summary: List vendors (admin)
      parameters:
        - in: query
          name: query
          schema: { type: string }
        - in: query
          name: page
          schema: { type: integer, minimum: 1, default: 1 }
        - in: query
          name: page_size
          schema: { type: integer, minimum: 1, maximum: 100, default: 20 }
        - in: query
          name: status
          schema: { type: string, enum: [active, inactive] }
        - in: query
          name: plan_code
          schema: { type: string }
        - in: query
          name: verified
          schema: { type: boolean }
      responses:
        '200':
          description: Paginated vendor list
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AdminVendorPagination'
        '401': { description: Unauthorized }
        '404': { description: Not found }
```

### `GET /api/v1/admin/vendors/{vendor_id}`
- Detail view with onboarding status, current subscription, KYC references.

### `PATCH /api/v1/admin/vendors/{vendor_id}`
- Body supports toggling `is_active`, `is_verified`, `notes`.

### `POST /api/v1/admin/vendors/{vendor_id}/verify`
- Convenience endpoint to mark vendor verified; optional audit payload.

## Subscriptions

### `GET /api/v1/admin/subscriptions`
- Filters: `vendor_id`, `plan_code`, `status`, `page`, `page_size`.
- Response: pagination wrapper of subscription rows (plan, start/end, paid_months, status).

### `POST /api/v1/subscriptions/{subscription_id}/activate`
- Body: `{ "paid_months": int }`
- Confirms activation/audit while returning updated subscription state.

## Audit Events

### `GET /api/v1/admin/audit-events`
- Filters: `page`, `page_size`, `admin_identifier`, `action`, `subject_type`, `subject_id`, `created_after`, `created_before`.
- Response: pagination wrapper containing audit event DTOs.

## Metrics (Optional)

### `GET /api/v1/admin/metrics`
- JSON fallback for dashboards when Prometheus `/metrics` is unavailable.
- Response example: `{ "appydex_vendors_total": 120, "appydex_bookings_today": 4 }`

---

**Schema references**
- `AdminVendor` should include: `id`, `name`, `owner_email`, `phone`, `plan_code`, `is_active`, `is_verified`, `onboarding_score`, `created_at`, `notes`.
- `AdminSubscription` should include: `id`, `vendor_id`, `plan_code`, `status`, `start_at`, `end_at`, `paid_months`.
- `AdminAuditEvent` should include: `id`, `admin_identifier`, `action`, `subject_type`, `subject_id`, `payload`, `created_at`.

Providing these endpoints will remove the need for mock fallbacks and enable full admin control-plane functionality.
