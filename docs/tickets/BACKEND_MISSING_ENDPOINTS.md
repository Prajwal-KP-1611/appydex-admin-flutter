# Backend API Requirements - Missing Endpoints

This document lists all backend endpoints required by the admin FE that are either missing or need updates.

## Priority: CRITICAL (Blockers for Production)

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

**Status:** Partial (refund missing)

#### 5.1 Refund Payment
```
POST /api/v1/admin/payments/{payment_id}/refund
Headers:
  Idempotency-Key: required
Body:
{
  "amount": 1500.00,
  "reason": "duplicate_charge|customer_request|error|other",
  "notes": "Customer contacted support..."
}

Response:
{
  "refund_id": "refund-uuid",
  "payment_id": "payment-uuid",
  "amount": 1500.00,
  "status": "pending|succeeded|failed",
  "created_at": "2025-11-07T10:30:00Z"
}
```

#### 5.2 Download Invoice
```
GET /api/v1/admin/payments/{payment_id}/invoice

Response:
{
  "invoice_url": "https://cdn.../invoice-123.pdf",
  "expires_at": "2025-11-07T12:00:00Z"
}
```

Or direct PDF download with appropriate headers.

---

### 6. Reviews Moderation & Takedown

**Status:** Partial (missing flags, vendor requests, bulk actions)

#### 6.1 List Reviews with Flags
```
GET /api/v1/admin/reviews
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

1. **Token Storage:** Can we move refresh token to httpOnly secure cookie? (Current: both tokens in memory/localStorage)
2. **Permissions:** Can we get flat permissions array in login/refresh response?
3. **Jobs:** What's the expected completion time for analytics exports? (Need for polling strategy)
4. **Rate Limits:** What are the limits for vendor flag submissions? (Need to show in UI)
5. **Audit:** Are all moderation actions automatically audited, or do we need separate endpoint?

---

## Contact

For questions or clarifications, reach out to:
- **Frontend Lead:** [Your Name]
- **Date:** 2025-11-07
