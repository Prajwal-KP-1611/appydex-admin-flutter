# Backend Implementation Priority List

**Date**: 2025-11-07  
**Purpose**: Prioritized list of backend changes needed for admin panel production deployment

---

## 🔴 CRITICAL PRIORITY (Week 1)

### 1. httpOnly Cookie Authentication
**Ticket**: `docs/tickets/BACKEND_HTTPONLY_COOKIE_AUTH.md`  
**Impact**: Security + UX - Enables persistent sessions on web without XSS risk  
**Endpoints Affected**:
- `POST /api/v1/admin/auth/verify-otp` - Update to set httpOnly cookie
- `POST /api/v1/admin/auth/refresh` - NEW endpoint for token refresh
- `POST /api/v1/admin/auth/logout` - Update to clear cookie

**Effort**: 4-6 hours  
**Dependencies**: None  
**Testing**: Frontend ready to test once backend deployed

---

### 2. Payments: Refund & Invoice
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 5  
**Impact**: Revenue operations - Admins can process refunds and generate invoices  
**Endpoints**:
- `POST /api/v1/admin/payments/{payment_id}/refund` - NEW
  - Requires `Idempotency-Key` header
  - Body: `{reason?: string}`
  - Response: Updated payment object with status="refunded"
  
- `GET /api/v1/admin/payments/{payment_id}/invoice` - NEW
  - Response: `{download_url: string, expires_at: string}`
  - Pre-signed URL or direct PDF download

**Effort**: 3-4 hours  
**Dependencies**: Payment processing integration (Stripe/PayPal?)  
**Testing**: Frontend implemented and ready

**Frontend Files**:
- `lib/repositories/payment_repo.dart`
- `lib/features/payments/payments_list_screen.dart`

---

### 3. Reviews: Moderation Actions
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 6  
**Impact**: Content moderation - Critical for maintaining platform quality  
**Endpoints**:
- `GET /api/v1/admin/reviews` - Update with filters (status, flagged, vendor_id)
- `GET /api/v1/admin/reviews/{review_id}` - Single review detail
- `POST /api/v1/admin/reviews/{review_id}/approve` - NEW
- `POST /api/v1/admin/reviews/{review_id}/hide` - NEW (requires reason)
- `POST /api/v1/admin/reviews/{review_id}/restore` - NEW
- `DELETE /api/v1/admin/reviews/{review_id}` - NEW (requires reason)

**Effort**: 4-6 hours  
**Dependencies**: Reviews table schema (status column, admin_notes, flag_reason)  
**Testing**: Full UI implemented with filters, dialogs, loading states

**Frontend Files**:
- `lib/models/review.dart`
- `lib/repositories/reviews_repo.dart`
- `lib/features/reviews/reviews_list_screen.dart`

---

## 🟡 HIGH PRIORITY (Week 2)

### 4. Analytics Dashboard Data
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 3  
**Impact**: Business intelligence - Insights into user behavior and platform performance  
**Endpoints**:
- `GET /api/v1/admin/analytics/top-searches` - NEW
  - Query: `start_date`, `end_date`, `limit`
  - Response: `[{query: string, count: number}]`
  
- `GET /api/v1/admin/analytics/ctr` - NEW
  - Query: `start_date`, `end_date`, `granularity` (day/week)
  - Response: `[{date: string, clicks: number, impressions: number, ctr: number}]`
  
- `POST /api/v1/admin/analytics/export` - NEW (long-running)
  - Body: `{start_date, end_date, format: "csv|excel"}`
  - Response: `{job_id: string}`
  - Requires: Job polling endpoint

**Effort**: 6-8 hours  
**Dependencies**: Analytics/tracking data collection, Job queue system  
**Testing**: Frontend NOT YET implemented (next on our roadmap)

---

### 5. Long-Running Jobs API
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 4  
**Impact**: UX for slow operations (exports, bulk updates)  
**Endpoints**:
- `GET /api/v1/admin/jobs/{job_id}` - NEW
  - Response: `{id, type, status, progress, result?, error?}`
  - States: pending → processing → completed|failed

**Effort**: 3-4 hours  
**Dependencies**: Background job processor (Celery, Bull, etc.)  
**Testing**: Frontend has JobPoller widget ready

**Frontend Files**:
- `lib/widgets/job_poller_button.dart` (already implemented)

---

### 6. Explicit Permissions Array
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 2  
**Impact**: RBAC security - Server-enforced permissions instead of client derivation  
**Endpoint Update**:
- `POST /api/v1/admin/auth/verify-otp` - Add `permissions` array to response
  ```json
  {
    "access_token": "...",
    "admin": {
      "id": 1,
      "email": "admin@example.com",
      "role": "admin",
      "permissions": [
        "vendors.view",
        "vendors.verify",
        "vendors.reject",
        "payments.view",
        "payments.refund",
        "reviews.view",
        "reviews.moderate",
        "analytics.view"
      ]
    }
  }
  ```

**Effort**: 2-3 hours  
**Dependencies**: Role-permission mapping in database  
**Testing**: Frontend currently derives permissions from role (works but not secure)

---

## 🟢 MEDIUM PRIORITY (Week 3)

### 7. Idempotency Key Support
**Ticket**: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` Section 1  
**Impact**: Reliability - Prevents duplicate operations from network retries  
**Implementation**: Accept `Idempotency-Key` header on mutating endpoints
- Store key + response in cache (Redis) for 24h
- If duplicate key received, return cached response (200, not 409)
- Apply to: refund, hide review, remove review, approve vendor

**Effort**: 4-5 hours  
**Dependencies**: Redis or similar cache  
**Testing**: Frontend sends keys automatically

---

### 8. CORS Localhost Support
**Ticket**: `docs/tickets/BACKEND_CORS_LOCALHOST_REQUEST.md`  
**Impact**: Developer experience - Simplifies local development  
**Implementation**: Update CORS regex to include localhost/127.0.0.1
```python
allow_origin_regex = r"^https?://(localhost|127\.0\.0\.1|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+)?$"
```

**Effort**: 30 minutes  
**Dependencies**: None  
**Testing**: App works at `http://localhost:61101` instead of IP

**Note**: Currently works with IP origins, so this is convenience not blocker

---

## 🔵 LOW PRIORITY (Future)

### 9. Advanced Reviews Features
- Vendor flag requests queue
- Bulk moderation actions
- Review flags with evidence URLs
- Moderation history timeline

**Effort**: 8-10 hours  
**Testing**: Frontend not implemented yet

---

### 10. Rate Limiting Headers
- Expose `X-RateLimit-*` headers in CORS
- Document rate limits in API

**Effort**: 1-2 hours

---

## Implementation Sequence

### Week 1: Core Functionality
1. **Day 1-2**: httpOnly Cookie Auth (critical for UX)
2. **Day 3**: Payments Refund + Invoice
3. **Day 4-5**: Reviews Moderation (6 endpoints)

**Deliverable**: Admin panel with working payments and reviews management

### Week 2: Analytics & Jobs
1. **Day 1-2**: Analytics endpoints (top searches, CTR)
2. **Day 3**: Long-running jobs API
3. **Day 4**: Analytics export endpoint
4. **Day 5**: Explicit permissions array

**Deliverable**: Full analytics dashboard + proper RBAC

### Week 3: Polish & Hardening
1. **Day 1-2**: Idempotency key support
2. **Day 3**: CORS improvements
3. **Day 4-5**: Testing, documentation, deployment

**Deliverable**: Production-ready admin API

---

## Testing Checklist

For each endpoint implementation:
- [ ] Write unit tests
- [ ] Test with Postman/curl
- [ ] Verify CORS headers
- [ ] Test idempotency (if applicable)
- [ ] Test error cases (400, 401, 403, 404, 422, 500)
- [ ] Coordinate with frontend team for integration test
- [ ] Update API documentation
- [ ] Deploy to staging
- [ ] Frontend team validates
- [ ] Deploy to production

---

## Frontend Integration Status

| Feature | Frontend Status | Backend Status | Blocker? |
|---------|----------------|----------------|----------|
| Default credentials removal | ✅ Complete | N/A | No |
| Token storage security | ✅ Complete | ⏳ Needs cookie auth | Yes (UX) |
| Payments refund | ✅ Complete | ❌ Missing | Yes |
| Invoice download | ✅ Complete | ❌ Missing | Yes |
| Reviews moderation | ✅ Complete | ❌ Missing | Yes |
| Analytics dashboard | ❌ Not started | ❌ Missing | No |
| CSP production fix | ❌ Not started | N/A | No |
| Server permissions | ❌ Not started | ❌ Missing | No |
| Integration tests | ❌ Not started | N/A | No |
| Error handling | ❌ Not started | N/A | No |

**Critical Path**: Cookie auth → Payments → Reviews → Analytics → Permissions

---

## Contact & Coordination

**Frontend Team**: Ready to test endpoints as soon as deployed to staging  
**Backend Team**: Please follow sequence above for smoothest integration

**Staging Environment**: TBD  
**Expected Production Date**: TBD (3 weeks after Week 1 completion)

---

## Related Documents

- `docs/tickets/BACKEND_HTTPONLY_COOKIE_AUTH.md` - Detailed auth flow
- `docs/tickets/BACKEND_MISSING_ENDPOINTS.md` - Full endpoint specs
- `docs/tickets/BACKEND_CORS_LOCALHOST_REQUEST.md` - CORS configuration
- `docs/PRODUCTION_FEATURES_IMPLEMENTATION.md` - Frontend progress

---

**Questions?** Contact frontend team or see detailed tickets above.
