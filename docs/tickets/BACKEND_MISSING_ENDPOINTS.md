# Backend API Requirements - Missing Endpoints

**Last Updated**: 2025-11-07  
**Status**: Frontend implementation complete for Payments & Reviews moderation

## 🎯 Quick Status Summary

### ✅ Frontend Ready (Awaiting Backend Implementation)
- **Payments**: Refund + Invoice Download (2 endpoints)
- **Reviews Moderation**: Full CRUD + 4 moderation actions (6 endpoints)
- **Auth**: httpOnly cookie flow (3 endpoint updates)

### ⏳ Not Yet Implemented (Frontend)
- **Analytics Dashboard**: Top Searches, CTR, Export (3 endpoints)
- **Advanced Reviews**: Vendor flags queue, bulk actions

### 🔧 Configuration Needed
- **CORS**: Add localhost support for development
- **Idempotency**: Support Idempotency-Key header
- **Permissions**: Return explicit permissions array in login response

---

This document lists all backend endpoints required by the admin FE that are either missing or need updates.

## Priority: CRITICAL (Blockers for Production)

### 0. CORS Configuration (BLOCKING ALL API CALLS)

**Status:** ⚠️ **PARTIAL** - Works for IP origins but not localhost  
**Affected:** All API endpoints at `https://api.appydex.co`

**Current Status:**
- ✅ Backend CORS is configured and working
- ✅ Allows requests from IP-based origins (e.g., `http://103.210.1.140:*`)
- ❌ Does NOT allow requests from `localhost` origins
- ❌ Does NOT allow requests from `127.0.0.1` origins

**Workaround (Development):**
Instead of accessing the app at `http://localhost:61101`, use your machine's IP address:
```
http://103.210.1.140:61101
```

**Current Backend CORS Configuration:**
```bash
# Test shows backend allows IP origins:
curl -X OPTIONS "https://api.appydex.co/api/v1/admin/auth/request-otp" \
  -H "Origin: http://103.210.1.140:37585" \
  -H "Access-Control-Request-Method: POST"

# Response:
# ✅ access-control-allow-origin: http://103.210.1.140:37585
# ✅ access-control-allow-credentials: true
# ✅ access-control-allow-methods: DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT

# But localhost fails:
curl -X OPTIONS "https://api.appydex.co/api/v1/admin/auth/request-otp" \
  -H "Origin: http://localhost:61101" \
  -H "Access-Control-Request-Method: POST"

# Response:
# ❌ 400 Bad Request
# ❌ No access-control-allow-origin header
```

**Recommended Backend Update (Optional):**

To support standard `localhost` development, add localhost/127.0.0.1 to allowed origins:

```python
# FastAPI/Starlette example
from fastapi.middleware.cors import CORSMiddleware
import re

# Use regex to match any IP and localhost origins
origins_regex = r"^https?://(localhost|127\.0\.0\.1|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(:\d+)?$"

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=origins_regex,
    allow_origins=[
        "https://admin.appydex.com",     # Production frontend
        "https://admin.appydex.co",      # Alternative production domain
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "Content-Type",
        "Authorization",
        "Idempotency-Key",
        "X-Request-ID",
    ],
    expose_headers=[
        "X-Request-ID",
        "X-RateLimit-Limit",
        "X-RateLimit-Remaining",
        "X-RateLimit-Reset",
    ],
    max_age=600,
)
```
```

**Express/Node.js example (if applicable):**
```javascript
const cors = require('cors');

app.use(cors({
  origin: [
    /^https?:\/\/localhost:\d+$/,           // Localhost any port
    /^https?:\/\/127\.0\.0\.1:\d+$/,        // 127.0.0.1 any port
    /^https?:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+$/,  // Any IP
    'https://admin.appydex.com',
    'https://admin.appydex.co',
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key', 'X-Request-ID'],
  exposedHeaders: ['X-Request-ID', 'X-RateLimit-Limit', 'X-RateLimit-Remaining'],
  maxAge: 600,
}));
```

**Impact:** 
- ✅ Frontend works when accessed via IP address
- ⚠️ Developers must use IP instead of `localhost` for API calls to work
- 💡 Optional enhancement: Add localhost/127.0.0.1 support for standard development workflow

**Priority:** � **LOW** (Workaround available) - Optional enhancement for developer convenience

---

### 1. Idempotency Support on Mutating Endpoints

**Status:** Required  
**Affected Endpoints:** All POST, PATCH, DELETE in `/api/v1/admin/*`

**Requirements:**
- Accept `Idempotency-Key` header on all POST, PATCH, DELETE requests
- Store idempotency keys with TTL (24-48 hours recommended)
- Return same response for duplicate requests with same key
- Return 409 Conflict if key exists but operation parameters differ

**Example:**
```
POST /api/v1/admin/vendors/{id}/verify
Headers:
  Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
  
Response: 200 (same response on retry)
```

**Critical for:** Vendor verify, refunds, bulk operations

---

### 2. Explicit Permissions Array in Session/Login Response

**Status:** Enhancement  
**Endpoint:** `POST /api/v1/admin/auth/login`, `POST /api/v1/admin/auth/refresh`

**Current:** Returns user with `roles` array  
**Needed:** Also return flat `permissions` array

**Example Response:**
```json
{
  "access": "jwt...",
  "refresh": "jwt...",
  "user": {
    "id": "admin-uuid",
    "email": "admin@appydex.com",
    "roles": ["vendor_admin"],
    "permissions": [
      "vendors:list",
      "vendors:view",
      "vendors:verify",
      "services:list",
      "services:create"
    ]
  }
}
```

**Fallback:** FE currently derives permissions from roles, but explicit list is more flexible.

---

## Priority: HIGH (Feature Completion)

### 3. Analytics Dashboard Endpoints

**Status:** Missing (all endpoints)

#### 3.1 Top Searches
```
GET /api/v1/admin/analytics/top_searches
Query params:
  - from: date (ISO8601)
  - to: date (ISO8601)
  - city?: string
  - category?: string
  - limit?: number (default 100)
  
Response:
{
  "data": [
    {
      "search_query": "plumber near me",
      "count": 1250,
      "avg_results": 8,
      "ctr": 0.45
    }
  ],
  "meta": {
    "from": "2025-10-01T00:00:00Z",
    "to": "2025-10-31T23:59:59Z",
    "total_searches": 50000
  }
}
```

#### 3.2 CTR Time Series
```
GET /api/v1/admin/analytics/ctr
Query params:
  - from: date
  - to: date
  - granularity: day|week|month (default: day)
  - city?: string
  - category?: string

Response:
{
  "data": [
    {
      "date": "2025-10-01",
      "searches": 1500,
      "clicks": 680,
      "ctr": 0.453
    }
  ]
}
```

#### 3.3 Analytics Export (Long-running Job)
```
POST /api/v1/admin/analytics/export
Body:
{
  "report_type": "searches|ctr|vendor_performance",
  "from": "2025-10-01",
  "to": "2025-10-31",
  "filters": {
    "city": "Mumbai",
    "category": "Home Services"
  }
}

Response:
{
  "job_id": "job-uuid",
  "status": "pending",
  "estimated_duration_seconds": 120
}
```

Then poll: `GET /api/v1/admin/jobs/{job_id}` (see section 4)

---

### 4. Long-Running Jobs API

**Status:** Missing

#### 4.1 Get Job Status
```
GET /api/v1/admin/jobs/{job_id}

Response:
{
  "id": "job-uuid",
  "type": "analytics_export",
  "status": "pending|processing|succeeded|failed",
  "progress_percent": 75,
  "created_at": "2025-11-07T10:00:00Z",
  "completed_at": null,
  "result": {
    "download_url": "https://cdn.../export.csv",
    "expires_at": "2025-11-08T10:00:00Z"
  },
  "error": null
}
```

**Polling:** FE will poll every 2s with exponential backoff (max 10s)

---

### 5. Payments & Invoices

**Status:** ✅ FRONTEND READY - Endpoints implemented, awaiting backend

#### 5.1 Refund Payment ✅ Frontend Implemented
```
POST /api/v1/admin/payments/{payment_id}/refund
Headers:
  Idempotency-Key: required (auto-generated: payment_id + timestamp)
Body:
{
  "reason": "duplicate_charge|customer_request|error|other" (optional)
}

Response:
{
  "id": "payment-uuid",
  "status": "refunded",
  "amount_cents": 1500,
  "currency": "USD",
  "refunded_at": "2025-11-07T10:30:00Z"
}

Frontend Implementation:
- lib/repositories/payment_repo.dart::refundPayment()
- lib/features/payments/payments_list_screen.dart (refund dialog)
- Generates Idempotency-Key: `${payment_id}-${timestamp}`
- Optional reason field with free-text input
```

#### 5.2 Download Invoice ✅ Frontend Implemented
```
GET /api/v1/admin/payments/{payment_id}/invoice

Response:
{
  "download_url": "https://cdn.../invoice-123.pdf",
  "expires_at": "2025-11-07T12:00:00Z"
}

Frontend Implementation:
- lib/repositories/payment_repo.dart::getInvoiceDownloadUrl()
- lib/features/payments/payments_list_screen.dart (download button)
- Shows URL in snackbar (could integrate url_launcher for direct download)
```

---

### 6. Reviews Moderation & Takedown

**Status:** ✅ FRONTEND READY - Core moderation implemented, advanced features pending

#### 6.1 List Reviews with Filters ✅ Frontend Implemented
```
GET /api/v1/admin/reviews
Query params:
  - skip, limit (pagination)
  - status: pending|approved|hidden|removed
  - flagged: true|false (optional)
  - vendor_id (optional)

Response:
{
  "items": [
    {
      "id": 123,
      "vendor_id": 456,
      "user_id": 789,
      "rating": 4,
      "comment": "Great service!",
      "status": "approved",
      "created_at": "2025-10-15T08:00:00Z",
      "updated_at": "2025-10-20T10:00:00Z",
      "vendor_name": "ABC Services",
      "user_name": "John Doe",
      "flag_reason": null,
      "admin_notes": null
    }
  ],
  "total": 123,
  "skip": 0,
  "limit": 100
}

Frontend Implementation:
- lib/models/review.dart (complete model)
- lib/repositories/reviews_repo.dart::list()
- lib/features/reviews/reviews_list_screen.dart (full UI with filters)
```

#### 6.2 Get Review Detail ✅ Frontend Implemented
```
GET /api/v1/admin/reviews/{review_id}

Response:
{
  "id": 123,
  "vendor_id": 456,
  "user_id": 789,
  "rating": 4,
  "comment": "Great service!",
  "status": "approved",
  "created_at": "2025-10-15T08:00:00Z",
  "updated_at": "2025-10-20T10:00:00Z",
  "vendor_name": "ABC Services",
  "user_name": "John Doe",
  "flag_reason": "spam",
  "admin_notes": "Verified legitimate review"
}

Frontend Implementation:
- lib/repositories/reviews_repo.dart::getById()
```

#### 6.3 Approve Review ✅ Frontend Implemented
```
POST /api/v1/admin/reviews/{review_id}/approve
Body (optional):
{
  "admin_notes": "Verified with vendor"
}

Response:
{
  "id": 123,
  "status": "approved",
  "updated_at": "2025-11-07T10:30:00Z"
}

Frontend Implementation:
- lib/repositories/reviews_repo.dart::approve()
- Approve button in review card (green)
```

#### 6.4 Hide Review ✅ Frontend Implemented
```
POST /api/v1/admin/reviews/{review_id}/hide
Body:
{
  "reason": "spam|abuse|inappropriate|other" (required)
}

Response:
{
  "id": 123,
  "status": "hidden",
  "updated_at": "2025-11-07T10:30:00Z"
}

Frontend Implementation:
- lib/repositories/reviews_repo.dart::hide()
- Hide button with reason dialog
```

#### 6.5 Restore Hidden Review ✅ Frontend Implemented
```
POST /api/v1/admin/reviews/{review_id}/restore

Response:
{
  "id": 123,
  "status": "approved",
  "updated_at": "2025-11-07T10:30:00Z"
}

Frontend Implementation:
- lib/repositories/reviews_repo.dart::restore()
- Restore button (shown for hidden reviews)
```

#### 6.6 Remove Review Permanently ✅ Frontend Implemented
```
DELETE /api/v1/admin/reviews/{review_id}
Body:
{
  "reason": "spam|abuse|illegal|other" (required)
}

Response: 204 No Content

Frontend Implementation:
- lib/repositories/reviews_repo.dart::remove()
- Remove button with confirmation dialog (red, destructive)
```

#### 6.7 Vendor Flag Requests Queue ⏳ NOT YET IMPLEMENTED
```
GET /api/v1/admin/review-flags
Query params:
  - page, page_size
  - status: published|hidden|removed
  - has_flags: true|false
  - reason_code: abuse|hate|spam|off_topic|...
  - vendor_id
  - from, to
  - search

Response:
{
  "data": [
    {
      "id": "review-uuid",
      "vendor_id": "vendor-uuid",
      "user_id": "user-uuid",
      "rating": 3,
      "title": "Not great",
      "body": "...",
      "status": "published",
      "flags_count": 1,
      "last_flag_reason": "abuse",
      "created_at": "2025-10-15T08:00:00Z",
      "updated_at": "2025-10-20T10:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total": 123
  }
}
```

#### 6.2 Get Review Detail (with flags)
```
GET /api/v1/admin/reviews/{review_id}

Response:
{
  "id": "review-uuid",
  "vendor_id": "vendor-uuid",
  "user_id": "user-uuid",
  "rating": 3,
  "title": "...",
  "body": "...",
  "status": "published",
  "flags": [
    {
      "id": "flag-uuid",
      "reporter_type": "vendor|admin",
      "reporter_id": "vendor-uuid",
      "reason_code": "abuse",
      "notes": "Contains profanity",
      "status": "open|accepted|rejected",
      "created_at": "2025-10-20T09:00:00Z"
    }
  ],
  "moderation_history": [
    {
      "action": "hide",
      "reason_code": "abuse",
      "actor_id": "admin-uuid",
      "notes": "Violates community guidelines",
      "timestamp": "2025-10-20T10:00:00Z"
    }
  ]
}
```

#### 6.3 Vendor Flag Requests Queue
```
GET /api/v1/admin/review-flags
Query params:
  - page, page_size
  - status: open|accepted|rejected
  - reason_code
  - vendor_id

Response:
{
  "data": [
    {
      "id": "flag-uuid",
      "review_id": "review-uuid",
      "reporter_type": "vendor",
      "reporter_id": "vendor-uuid",
      "reason_code": "off_topic",
      "notes": "Review is about wrong business",
      "evidence_urls": ["https://..."],
      "status": "open",
      "created_at": "2025-10-20T09:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total": 15
  }
}
```

#### 6.4 Take Moderation Action (Hide/Remove/Restore)
```
PATCH /api/v1/admin/reviews/{review_id}
Headers:
  Idempotency-Key: required
Body:
{
  "action": "hide|remove|restore",
  "reason_code": "abuse|hate|spam|off_topic|conflict_of_interest|personal_info|ip_violation|profanity|other",
  "notes": "Clear violation of ToS, contains hate speech",
  "evidence_urls": ["https://..."],
  "notify_vendor": true,
  "notify_reviewer": false
}

Response:
{
  "id": "review-uuid",
  "status": "hidden",
  "moderated_at": "2025-10-20T10:30:00Z",
  "moderated_by": "admin-uuid"
}
```

#### 6.5 Resolve Vendor Flag
```
POST /api/v1/admin/review-flags/{flag_id}/resolve
Headers:
  Idempotency-Key: required
Body:
{
  "decision": "accept|reject",
  "action_if_accept": "hide|remove",
  "reason_code": "spam",
  "notes": "Bot network pattern detected",
  "notify_vendor": true
}

Response:
{
  "ok": true,
  "flag": {
    "id": "flag-uuid",
    "status": "accepted",
    "resolved_at": "2025-10-20T11:00:00Z",
    "resolved_by": "admin-uuid"
  },
  "review": {
    "id": "review-uuid",
    "status": "removed"
  }
}
```

#### 6.6 Create Admin Flag (Optional)
```
POST /api/v1/admin/reviews/{review_id}/flag
Headers:
  Idempotency-Key: required
Body:
{
  "reason_code": "abuse",
  "notes": "Contains slur",
  "evidence_urls": ["https://..."]
}

Response:
{
  "flag_id": "flag-uuid",
  "review_id": "review-uuid",
  "status": "open",
  "created_at": "2025-10-20T11:30:00Z"
}
```

---

## Priority: MEDIUM (Polish & Enhancements)

### 7. Send Notification (Manual)

**Status:** May exist, need to verify

```
POST /api/v1/admin/notifications/send
Body:
{
  "target_type": "vendor|user",
  "target_id": "uuid",
  "template_id": "review_takedown_notice",
  "context": {
    "review_id": "review-uuid",
    "action": "removed",
    "reason_code": "abuse"
  }
}

Response:
{
  "notification_id": "notif-uuid",
  "status": "sent",
  "sent_at": "2025-10-20T12:00:00Z"
}
```

---

### 8. Plans Activate/Deactivate

**Status:** Verify if exists

```
PATCH /api/v1/admin/plans/{plan_id}
Headers:
  Idempotency-Key: required
Body:
{
  "is_active": true|false
}

Response:
{
  "id": "plan-uuid",
  "is_active": true,
  "updated_at": "2025-11-07T10:00:00Z"
}
```

---

### 9. Users Anonymize/Consent Toggles

**Status:** Verify if exists

```
POST /api/v1/admin/users/{user_id}/anonymize
Headers:
  Idempotency-Key: required

Response:
{
  "id": "user-uuid",
  "status": "anonymized",
  "anonymized_at": "2025-11-07T10:00:00Z"
}
```

---

### 10. Campaigns Manual Credit

**Status:** Verify if exists

```
POST /api/v1/admin/campaigns/{campaign_id}/credit
Headers:
  Idempotency-Key: required
Body:
{
  "user_id": "user-uuid",
  "amount": 100,
  "reason": "Customer service compensation"
}

Response:
{
  "credit_id": "credit-uuid",
  "amount": 100,
  "created_at": "2025-11-07T10:00:00Z"
}
```

---

### 11. System Health & Backup (Sudo)

**Status:** Optional, for system admins

```
GET /api/v1/admin/system/health

Response:
{
  "status": "healthy",
  "services": {
    "database": "ok",
    "redis": "ok",
    "storage": "ok"
  },
  "timestamp": "2025-11-07T10:00:00Z"
}
```

```
POST /api/v1/admin/system/backup
Headers:
  Idempotency-Key: required

Response:
{
  "job_id": "job-uuid",
  "status": "pending"
}
```

---

## Validation & Error Responses

### Required Validations

1. **Idempotency-Key**
   - Return 400 if missing on operations requiring it
   - Return 409 if key exists with different parameters

2. **Permissions**
   - Return 403 with clear message if admin lacks permission
   - Include `required_permission` in error response

3. **Rate Limiting**
   - Return 429 with `Retry-After` header
   - Include `rate_limit_reset` timestamp

### Standard Error Format

```json
{
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to perform this action",
    "required_permission": "payments:refund",
    "trace_id": "trace-uuid"
  }
}
```

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": {
      "amount": ["Must be greater than 0"],
      "reason": ["Required field"]
    },
    "trace_id": "trace-uuid"
  }
}
```

---

## Implementation Priority

### Phase 0 (OPTIONAL - Developer Convenience)
**💡 Nice to have but workaround exists:**
0. **CORS Enhancement** - Add localhost/127.0.0.1 to allowed origins (currently works via IP address)

### Phase 1 (CRITICAL - Week 1)
1. Idempotency support on all mutating endpoints
2. Permissions array in auth responses
3. Reviews moderation endpoints (6.4, 6.5)
4. Payments refund (5.1)

### Phase 2 (HIGH - Week 2)
5. Analytics endpoints (3.1, 3.2, 3.3)
6. Jobs API (4.1)
7. Reviews flags/queue (6.1, 6.2, 6.3, 6.6)
8. Invoice download (5.2)

### Phase 3 (MEDIUM - Week 3)
9. Notifications API (7)
10. Plans activate/deactivate (8)
11. User anonymize (9)
12. Campaigns manual credit (10)

### Phase 4 (OPTIONAL)
13. System health & backup (11)

---

## Testing Requirements

For each endpoint, backend must:
1. Accept and validate Idempotency-Key
2. Return consistent trace_id
3. Enforce RBAC (return 403 if no permission)
4. Rate limit appropriately
5. Log all admin actions to audit trail

---

## Questions for Backend Team

1. **� CORS Enhancement (Optional):** Would you like to add `localhost`/`127.0.0.1` to allowed origins for developer convenience? Currently works fine with IP addresses. (See section 0 above for suggested config)
2. **Token Storage:** Can we move refresh token to httpOnly secure cookie? (Current: both tokens in memory/localStorage)
3. **Permissions:** Can we get flat permissions array in login/refresh response?
4. **Jobs:** What's the expected completion time for analytics exports? (Need for polling strategy)
5. **Rate Limits:** What are the limits for vendor flag submissions? (Need to show in UI)
6. **Audit:** Are all moderation actions automatically audited, or do we need separate endpoint?

---

## Contact

For questions or clarifications, reach out to:
- **Frontend Lead:** [Your Name]
- **Date:** 2025-11-07
