# 🎯 Backend Ticket: Reviews Takedown & Moderation System

> **⏳ STATUS: READY FOR IMPLEMENTATION**  
> **Comprehensive specification complete - Ready for backend development**  
> **Created:** November 12, 2025  
> **Priority:** 🔴 HIGH

**Priority:** HIGH  
**Ticket ID:** BACKEND-REVIEWS-002  
**Date Created:** November 12, 2025  
**Status:** ⏳ **PENDING BACKEND IMPLEMENTATION**  
**Estimated Effort:** 3-4 days  
**Assignee:** Backend Team

---

## 📋 Executive Summary

The admin frontend has **partial coverage** for review moderation (67% - 6/9 endpoints). Core review CRUD operations exist, but the **vendor flag/takedown request system is missing** (3 endpoints):

### ✅ Already Implemented (No Action Needed)
- ✅ `GET /api/v1/admin/reviews` - List reviews ✅
- ✅ `GET /api/v1/admin/reviews/{review_id}` - Get review detail ✅
- ✅ `POST /api/v1/admin/reviews/{review_id}/hide` - Hide review ✅
- ✅ `POST /api/v1/admin/reviews/{review_id}/restore` - Restore hidden review ✅
- ✅ `DELETE /api/v1/admin/reviews/{review_id}` - Remove review permanently ✅
- ✅ (DEPRECATED) `POST /api/v1/admin/reviews/{review_id}/approve` - No longer used ✅

### 🎯 Endpoints to Implement (This Ticket)
1. ⏳ `GET /api/v1/admin/reviews/takedown-requests` - List vendor flag requests queue
2. ⏳ `GET /api/v1/admin/reviews/takedown-requests/{request_id}` - Get takedown request details
3. ⏳ `POST /api/v1/admin/reviews/takedown-requests/{request_id}/resolve` - Resolve (accept/reject) takedown request

---

## 🎯 Use Case: Vendor Flag/Takedown System

**Problem:** Vendors need a way to flag problematic reviews (fake, defamatory, competitor sabotage, etc.) without directly contacting admins.

**Solution:** Formal takedown request system where:
1. Vendor flags a review with reason and evidence
2. Request appears in admin queue
3. Admin reviews evidence and decides to accept (hide/remove) or reject
4. Both parties get notified of outcome

---

## 🎯 Missing Endpoints

### 1. GET /api/v1/admin/reviews/takedown-requests

**Purpose:** List all vendor takedown requests for admin review queue

**Path:** `/api/v1/admin/reviews/takedown-requests`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `reviews:moderate` or `super_admin`

#### Request

**Query Parameters:**
```typescript
{
  page?: number;              // Page number (default: 1)
  page_size?: number;         // Items per page (default: 25, max: 100)
  status?: string;            // "open" | "accepted" | "rejected" (default: "open")
  reason_code?: string;       // Filter by reason: "abuse", "spam", "off_topic", etc.
  vendor_id?: string;         // Filter by vendor UUID
  from_date?: string;         // ISO 8601 date
  to_date?: string;           // ISO 8601 date
  sort_by?: string;           // "created_at" | "priority" (default: "created_at")
  sort_order?: string;        // "asc" | "desc" (default: "desc")
}
```

**Example Request:**
```bash
GET /api/v1/admin/reviews/takedown-requests?status=open&sort_by=created_at&sort_order=desc
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "request-uuid-123",
      "request_number": "TR-2025-001234",
      "status": "open",
      "review": {
        "id": "review-uuid",
        "rating": 1,
        "title": "Terrible service",
        "body": "They never showed up and charged me anyway!",
        "status": "published",
        "created_at": "2025-11-01T10:00:00Z",
        "reviewer": {
          "id": "user-uuid",
          "name": "Anonymous User",
          "total_reviews": 2,
          "trust_score": 45
        }
      },
      "vendor": {
        "id": "vendor-uuid",
        "name": "ABC Services",
        "display_name": "ABC Professional Services",
        "logo": "https://cdn.../vendor.jpg"
      },
      "reason_code": "defamation",
      "reason_description": "This review contains false and defamatory statements",
      "evidence": [
        {
          "type": "image",
          "url": "https://cdn.../evidence1.jpg",
          "description": "Proof of service completion - signed invoice"
        },
        {
          "type": "document",
          "url": "https://cdn.../evidence2.pdf",
          "description": "Customer SMS confirmation of satisfaction"
        }
      ],
      "vendor_notes": "Customer was completely satisfied during the service. This review was posted 2 weeks later after we refused to do additional free work.",
      "priority": "high",
      "created_at": "2025-11-10T14:30:00Z",
      "resolved_at": null,
      "resolved_by": null,
      "resolution_notes": null,
      "admin_notes": null
    },
    {
      "id": "request-uuid-456",
      "request_number": "TR-2025-001235",
      "status": "open",
      "review": {
        "id": "review-uuid-2",
        "rating": 5,
        "title": "Best service ever!",
        "body": "Amazing work, highly recommend!",
        "status": "published",
        "created_at": "2025-11-05T16:00:00Z",
        "reviewer": {
          "id": "user-uuid-2",
          "name": "John Doe",
          "total_reviews": 1,
          "trust_score": 30
        }
      },
      "vendor": {
        "id": "competitor-vendor-uuid",
        "name": "XYZ Competitors",
        "display_name": "XYZ Services"
      },
      "reason_code": "fake_review",
      "reason_description": "This is a competitor posting fake positive reviews",
      "evidence": [
        {
          "type": "text",
          "description": "IP address analysis shows reviewer and vendor logged in from same location"
        }
      ],
      "vendor_notes": "This person never used our service. They're a competitor trying to game the system.",
      "priority": "medium",
      "created_at": "2025-11-11T09:00:00Z",
      "resolved_at": null,
      "resolved_by": null,
      "resolution_notes": null,
      "admin_notes": null
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 42,
    "total_pages": 2,
    "has_next": true,
    "has_prev": false,
    "summary": {
      "open": 42,
      "accepted": 156,
      "rejected": 89,
      "avg_resolution_time_hours": 18.5
    }
  }
}
```

**Error Responses:**

**403 Forbidden:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to view takedown requests",
    "required_permission": "reviews:moderate"
  }
}
```

#### Reason Codes

| Code | Description | Severity |
|------|-------------|----------|
| `abuse` | Abusive language, hate speech | High |
| `defamation` | False, defamatory statements | High |
| `spam` | Spam, irrelevant content | Medium |
| `off_topic` | Review about wrong business | Medium |
| `fake_review` | Suspected fake/paid review | High |
| `competitor_sabotage` | Competitor posting negative review | High |
| `personal_info` | Contains private information | High |
| `profanity` | Excessive profanity | Medium |
| `extortion` | Threatening to change review for money | High |
| `duplicate` | Duplicate review from same user | Low |
| `other` | Other reason (see description) | Varies |

#### Priority Calculation

Auto-calculated based on:
- `high`: abuse, defamation, fake_review, competitor_sabotage, extortion
- `medium`: spam, off_topic, personal_info, profanity
- `low`: duplicate, other

#### Implementation Notes

1. **Data Source:** Query from `review_takedown_requests` table with joins:
   - `reviews` table for review data
   - `users` table for reviewer info
   - `vendors` table for requestor info
   - `admin_users` table for resolver info (if resolved)

2. **Evidence Storage:**
   - Store evidence URLs in JSONB array
   - Support: images, documents, text descriptions
   - Evidence uploaded to S3/GCS with expiry (90 days)

3. **Default Sort:**
   - Show `open` requests first
   - Sort by priority (high → medium → low)
   - Then by created_at DESC (newest first)

4. **Performance:**
   - Add index on `(status, priority, created_at)`
   - Cache open count for 5 minutes

---

### 2. GET /api/v1/admin/reviews/takedown-requests/{request_id}

**Purpose:** Get detailed information about a specific takedown request

**Path:** `/api/v1/admin/reviews/takedown-requests/{request_id}`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `reviews:moderate` or `super_admin`

#### Request

**Path Parameters:**
- `request_id` (string, required) - UUID of the takedown request

**Example Request:**
```bash
GET /api/v1/admin/reviews/takedown-requests/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "request-uuid-123",
    "request_number": "TR-2025-001234",
    "status": "open",
    "review": {
      "id": "review-uuid",
      "rating": 1,
      "title": "Terrible service",
      "body": "They never showed up and charged me anyway! This company is a scam. The owner is a thief who preys on elderly customers.",
      "status": "published",
      "created_at": "2025-11-01T10:00:00Z",
      "updated_at": "2025-11-01T10:00:00Z",
      "reviewer": {
        "id": "user-uuid",
        "name": "Anonymous User",
        "email": "user@example.com",
        "phone": "+919876543210",
        "profile_image": null,
        "account_created_at": "2025-10-30T08:00:00Z",
        "total_reviews": 2,
        "total_bookings": 1,
        "trust_score": 45,
        "risk_flags": ["new_account", "low_activity"]
      },
      "booking": {
        "id": "booking-uuid",
        "booking_number": "BK-2025-005432",
        "status": "completed",
        "scheduled_at": "2025-10-31T14:00:00Z",
        "completed_at": "2025-10-31T16:30:00Z",
        "amount_cents": 500000,
        "payment_status": "paid",
        "has_dispute": false
      },
      "moderation_history": []
    },
    "vendor": {
      "id": "vendor-uuid",
      "name": "ABC Services",
      "display_name": "ABC Professional Services",
      "email": "vendor@abc.com",
      "phone": "+919876543000",
      "logo": "https://cdn.../vendor.jpg",
      "rating": 4.5,
      "total_reviews": 450,
      "total_takedown_requests": 3,
      "accepted_takedowns": 1,
      "rejected_takedowns": 2
    },
    "reason_code": "defamation",
    "reason_description": "This review contains false and defamatory statements. We completed the service on time and have proof of customer satisfaction.",
    "evidence": [
      {
        "id": "evidence-uuid-1",
        "type": "image",
        "url": "https://cdn.../evidence1.jpg",
        "thumbnail_url": "https://cdn.../thumb_evidence1.jpg",
        "filename": "signed_invoice.jpg",
        "size_bytes": 245000,
        "description": "Proof of service completion - signed invoice showing customer signature",
        "uploaded_at": "2025-11-10T14:25:00Z"
      },
      {
        "id": "evidence-uuid-2",
        "type": "document",
        "url": "https://cdn.../evidence2.pdf",
        "filename": "sms_confirmation.pdf",
        "size_bytes": 128000,
        "description": "Customer SMS confirmation: 'Thank you for great work, very satisfied'",
        "uploaded_at": "2025-11-10T14:26:00Z"
      },
      {
        "id": "evidence-uuid-3",
        "type": "text",
        "content": "Customer called us 2 weeks after service asking for additional free work. We politely declined as it was outside the original scope. Negative review was posted the next day.",
        "description": "Timeline of events",
        "uploaded_at": "2025-11-10T14:28:00Z"
      }
    ],
    "vendor_notes": "Customer was completely satisfied during the service. This review was posted 2 weeks later after we refused to do additional free work unrelated to the original booking.",
    "priority": "high",
    "created_at": "2025-11-10T14:30:00Z",
    "updated_at": "2025-11-10T14:30:00Z",
    "resolved_at": null,
    "resolved_by": null,
    "resolution": null,
    "admin_notes": null,
    "internal_analysis": {
      "similar_reviews_by_user": [],
      "similar_complaints_against_vendor": 0,
      "user_behavior_flags": ["new_account", "single_booking"],
      "review_timing_suspicious": true,
      "sentiment_analysis": "highly_negative"
    },
    "timeline": [
      {
        "event": "booking_completed",
        "timestamp": "2025-10-31T16:30:00Z",
        "details": "Service completed successfully"
      },
      {
        "event": "review_posted",
        "timestamp": "2025-11-01T10:00:00Z",
        "details": "Customer posted negative review"
      },
      {
        "event": "takedown_requested",
        "timestamp": "2025-11-10T14:30:00Z",
        "actor": "vendor",
        "details": "Vendor submitted takedown request with evidence"
      }
    ]
  }
}
```

**Success Response (200 OK) - Resolved Request:**
```json
{
  "success": true,
  "data": {
    "id": "request-uuid-789",
    "status": "accepted",
    "resolved_at": "2025-11-11T10:00:00Z",
    "resolved_by": {
      "id": "admin-uuid",
      "name": "Admin User",
      "email": "admin@appydex.com"
    },
    "resolution": {
      "decision": "accept",
      "action_taken": "remove",
      "reason": "Review contains demonstrably false claims with clear evidence provided",
      "admin_notes": "Clear evidence of service completion. Customer satisfaction confirmed via SMS. Review posted 2 weeks later after vendor declined additional free work. This constitutes retaliation, not legitimate feedback.",
      "review_status_after": "removed",
      "vendor_notified": true,
      "reviewer_notified": true
    }
  }
}
```

**Error Responses:**

**404 Not Found:**
```json
{
  "success": false,
  "error": {
    "code": "REQUEST_NOT_FOUND",
    "message": "Takedown request not found",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

#### Implementation Notes

1. **Complete Context:**
   - Fetch all related entities for informed decision
   - Include booking details (was service actually completed?)
   - Include user risk profile (trust score, review history)
   - Include vendor track record (past takedown requests)

2. **Internal Analysis:**
   - Run automated checks: timing, sentiment, user behavior
   - Flag suspicious patterns
   - Help admin make informed decision

3. **Evidence Display:**
   - Support multiple evidence types
   - Generate thumbnails for images
   - Store metadata (filename, size, upload time)

---

### 3. POST /api/v1/admin/reviews/takedown-requests/{request_id}/resolve

**Purpose:** Admin accepts or rejects vendor takedown request

**Path:** `/api/v1/admin/reviews/takedown-requests/{request_id}/resolve`  
**Method:** `POST`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `reviews:moderate` or `super_admin`  
**Idempotency:** Required - `Idempotency-Key` header

#### Request

**Path Parameters:**
- `request_id` (string, required) - UUID of the takedown request

**Headers:**
```
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

**Body:**
```typescript
{
  decision: string;              // "accept" | "reject" (required)
  action?: string;               // "hide" | "remove" (required if decision = "accept")
  reason: string;                // Admin's reasoning (required, 50-2000 chars)
  admin_notes?: string;          // Internal notes, not shared with vendor/user (optional)
  notify_vendor: boolean;        // Send notification to vendor (default: true)
  notify_reviewer: boolean;      // Send notification to reviewer (default: depends on action)
}
```

**Example Request - Accept & Remove:**
```bash
POST /api/v1/admin/reviews/takedown-requests/550e8400-e29b-41d4-a716-446655440000/resolve
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655441234
Content-Type: application/json

{
  "decision": "accept",
  "action": "remove",
  "reason": "Review contains demonstrably false claims. Evidence clearly shows service was completed satisfactorily and customer confirmed satisfaction. Review appears to be retaliation after vendor declined additional free work.",
  "admin_notes": "Clear case of retaliation. Customer has low trust score and single booking. Consider flagging for future review.",
  "notify_vendor": true,
  "notify_reviewer": true
}
```

**Example Request - Reject:**
```bash
POST /api/v1/admin/reviews/takedown-requests/550e8400-e29b-41d4-a716-446655440000/resolve
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655441235
Content-Type: application/json

{
  "decision": "reject",
  "reason": "While the timing is suspicious, the review describes legitimate service issues. Evidence provided does not conclusively disprove the reviewer's claims. Vendor should address the concerns directly with the customer.",
  "admin_notes": "Borderline case. Vendor has history of similar complaints. May need to investigate service quality.",
  "notify_vendor": true,
  "notify_reviewer": false
}
```

#### Response

**Success Response (200 OK) - Accepted:**
```json
{
  "success": true,
  "data": {
    "request": {
      "id": "request-uuid-123",
      "request_number": "TR-2025-001234",
      "status": "accepted",
      "resolved_at": "2025-11-12T11:00:00Z",
      "resolved_by": {
        "id": "admin-uuid",
        "name": "Admin User",
        "email": "admin@appydex.com"
      },
      "resolution": {
        "decision": "accept",
        "action_taken": "remove",
        "reason": "Review contains demonstrably false claims...",
        "admin_notes": "Clear case of retaliation...",
        "vendor_notified": true,
        "reviewer_notified": true
      }
    },
    "review": {
      "id": "review-uuid",
      "status": "removed",
      "removed_at": "2025-11-12T11:00:00Z",
      "removed_by": "admin-uuid",
      "removal_reason": "Takedown request accepted - false claims"
    },
    "notifications_sent": {
      "vendor": {
        "email": true,
        "in_app": true
      },
      "reviewer": {
        "email": true,
        "in_app": true
      }
    }
  }
}
```

**Success Response (200 OK) - Rejected:**
```json
{
  "success": true,
  "data": {
    "request": {
      "id": "request-uuid-456",
      "request_number": "TR-2025-001235",
      "status": "rejected",
      "resolved_at": "2025-11-12T11:05:00Z",
      "resolved_by": {
        "id": "admin-uuid",
        "name": "Admin User"
      },
      "resolution": {
        "decision": "reject",
        "reason": "Evidence does not conclusively disprove reviewer's claims...",
        "admin_notes": "Borderline case...",
        "vendor_notified": true,
        "reviewer_notified": false
      }
    },
    "review": {
      "id": "review-uuid-2",
      "status": "published",
      "remains_visible": true
    },
    "notifications_sent": {
      "vendor": {
        "email": true,
        "in_app": true
      }
    }
  }
}
```

**Error Responses:**

**400 Bad Request - Missing Action:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "action": ["Required when decision is 'accept'"]
    }
  }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": {
    "code": "REQUEST_NOT_FOUND",
    "message": "Takedown request not found",
    "request_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

**409 Conflict - Already Resolved:**
```json
{
  "success": false,
  "error": {
    "code": "ALREADY_RESOLVED",
    "message": "This takedown request has already been resolved",
    "current_status": "accepted",
    "resolved_at": "2025-11-11T10:00:00Z",
    "resolved_by": "admin-uuid-other"
  }
}
```

**409 Conflict - Idempotency:**
```json
{
  "success": false,
  "error": {
    "code": "IDEMPOTENCY_CONFLICT",
    "message": "Operation already completed with different parameters",
    "idempotency_key": "550e8400-e29b-41d4-a716-446655441234"
  }
}
```

#### Action Types

| Action | Effect | Reviewer Notified? | Review Visibility |
|--------|--------|-------------------|-------------------|
| `hide` | Review hidden, can be restored | Optional (default: no) | Hidden from public, vendor can see |
| `remove` | Review permanently removed | Yes (default) | Completely removed |

#### Notification Templates

**Vendor - Accepted:**
```
Subject: Takedown Request Accepted - Review Removed

Your takedown request TR-2025-001234 has been accepted.

Action Taken: Review permanently removed

Admin Reasoning:
"Review contains demonstrably false claims. Evidence clearly shows..."

The review is no longer visible to customers.

Thank you for providing clear evidence.
```

**Vendor - Rejected:**
```
Subject: Takedown Request Rejected - Review Remains

Your takedown request TR-2025-001235 has been rejected.

Admin Reasoning:
"Evidence does not conclusively disprove reviewer's claims..."

The review will remain visible. We recommend addressing the customer's concerns directly.

You can appeal this decision by contacting support with additional evidence.
```

**Reviewer - Review Removed:**
```
Subject: Your Review Has Been Removed

Your review of ABC Services has been removed after admin investigation.

Reason:
"Review contains demonstrably false claims..."

If you believe this was done in error, please contact support with supporting evidence.
```

#### Implementation Notes

1. **Atomic Transaction:**
   - Update takedown_request status
   - Update review status (if accepted)
   - Create audit log entry
   - Queue notification jobs
   - All in single transaction

2. **Idempotency:**
   - Store idempotency key with resolution
   - TTL: 24 hours
   - Return same response for duplicate requests

3. **Review Action:**
   - If action = "hide": Set review.status = "hidden"
   - If action = "remove": Set review.status = "removed", soft delete
   - Add moderation_history entry to review

4. **Notifications:**
   - Queue background jobs for email/in-app notifications
   - Use template based on decision/action
   - Include admin reasoning (sanitized)

5. **Audit Trail:**
   - Log to audit_logs table
   - Include: admin_id, request_id, review_id, decision, reasoning
   - Store before/after state

6. **Concurrency:**
   - Use row-level locking to prevent race conditions
   - Check if already resolved before processing

---

## 🔒 Security & Validation

### Authentication
- All endpoints require valid JWT Bearer token
- Token must have required permissions

### Authorization (RBAC)

| Endpoint | Required Permission | Alternative |
|----------|-------------------|-------------|
| `GET /admin/reviews/takedown-requests` | `reviews:moderate` | `super_admin` |
| `GET /admin/reviews/takedown-requests/{id}` | `reviews:moderate` | `super_admin` |
| `POST /admin/reviews/takedown-requests/{id}/resolve` | `reviews:moderate` | `super_admin` |

### Input Validation

**Decision Field:**
- Must be "accept" or "reject"
- Cannot change after resolution

**Action Field:**
- Required if decision = "accept"
- Must be "hide" or "remove"
- Not allowed if decision = "reject"

**Reason Field:**
- Required for all decisions
- Length: 50-2000 characters
- Must be meaningful (reject Lorem Ipsum, test data)

**Admin Notes:**
- Optional, max 5000 characters
- Internal only, never shared

### Rate Limiting

- List endpoint: 60 requests per minute per admin
- Detail endpoint: 120 requests per minute per admin
- Resolve endpoint: 30 requests per minute per admin

---

## 📊 Database Schema

**New Table: `review_takedown_requests`**

```sql
CREATE TABLE review_takedown_requests (
  id UUID PRIMARY KEY,
  request_number VARCHAR(50) UNIQUE NOT NULL,
  review_id UUID NOT NULL REFERENCES reviews(id),
  vendor_id UUID NOT NULL REFERENCES vendors(id),
  status VARCHAR(20) NOT NULL DEFAULT 'open',
  reason_code VARCHAR(50) NOT NULL,
  reason_description TEXT NOT NULL,
  evidence JSONB,
  vendor_notes TEXT,
  priority VARCHAR(20) NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  resolved_at TIMESTAMP,
  resolved_by UUID REFERENCES admin_users(id),
  decision VARCHAR(20),
  action_taken VARCHAR(20),
  resolution_reason TEXT,
  admin_notes TEXT,
  
  INDEX idx_status_priority_created (status, priority, created_at DESC),
  INDEX idx_vendor_status (vendor_id, status),
  INDEX idx_review_id (review_id),
  CONSTRAINT chk_status CHECK (status IN ('open', 'accepted', 'rejected')),
  CONSTRAINT chk_decision CHECK (decision IN ('accept', 'reject', NULL)),
  CONSTRAINT chk_action CHECK (action_taken IN ('hide', 'remove', NULL))
);
```

**Modify Table: `reviews`**

```sql
ALTER TABLE reviews ADD COLUMN has_takedown_request BOOLEAN DEFAULT FALSE;
ALTER TABLE reviews ADD COLUMN takedown_request_count INT DEFAULT 0;

CREATE INDEX idx_reviews_has_takedown ON reviews(has_takedown_request) 
  WHERE has_takedown_request = TRUE;
```

---

## 🧪 Testing Requirements

### Unit Tests
- [ ] List takedown requests with filters
- [ ] Get takedown request detail
- [ ] Resolve - accept with hide action
- [ ] Resolve - accept with remove action
- [ ] Resolve - reject
- [ ] Reject already resolved request
- [ ] Validate required fields
- [ ] Idempotency key handling

### Integration Tests
- [ ] Create takedown request (vendor flow)
- [ ] Admin accepts and review is removed
- [ ] Admin rejects and review remains
- [ ] Notifications sent correctly
- [ ] Audit log created
- [ ] Concurrent resolution attempts (locking)

### Performance Tests
- [ ] List query with 10K+ requests
- [ ] Detail query with complex evidence

### Manual Testing Checklist
- [ ] View open takedown requests
- [ ] View accepted/rejected requests
- [ ] Filter by reason code
- [ ] Sort by priority
- [ ] View request detail with evidence
- [ ] Accept request - hide review
- [ ] Accept request - remove review
- [ ] Reject request
- [ ] Verify notifications sent
- [ ] Try to resolve same request twice
- [ ] Test idempotency

---

## 📦 Deliverables

### Code
- [ ] Implement 3 new endpoints
- [ ] Create `review_takedown_requests` table
- [ ] Add indexes
- [ ] Implement resolution logic
- [ ] Add notification jobs
- [ ] Add audit logging

### Documentation
- [ ] API documentation in OpenAPI spec
- [ ] Takedown request workflow documentation
- [ ] Admin moderation guidelines

### Testing
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] Manual testing completed

---

## ✅ Acceptance Criteria

- [x] Admins can view queue of open takedown requests
- [x] Admins can see complete request details with evidence
- [x] Admins can accept requests (hide or remove review)
- [x] Admins can reject requests (review remains)
- [x] Vendors get notified of decision
- [x] Reviewers get notified when review is removed
- [x] Audit trail captures all actions
- [x] Idempotency prevents duplicate resolutions

---

## 🚀 Implementation Package Delivered

**Complete implementation package is now available:**

### 📦 What's Included

1. **FastAPI Router Implementation**
   - File: `docs/backend-tickets/IMPLEMENTATION_reviews_takedown.py`
   - All 3 endpoints with complete schemas
   - Request/response validation
   - Error handling
   - Comprehensive comments

2. **Database Migration SQL**
   - CREATE TABLE for `review_takedown_requests`
   - 4 performance indexes
   - Auto-numbering trigger
   - Review flag update trigger
   - ALTER TABLE for `reviews`

3. **Step-by-Step Implementation Guide**
   - File: `docs/backend-tickets/IMPLEMENTATION_GUIDE_reviews_takedown.md`
   - 5-step quick start
   - Complete testing guide with 10 test scenarios
   - Troubleshooting section
   - Performance optimization tips
   - Success criteria checklist

### 🎯 Quick Start for Backend Team

1. **Copy router file:**
   ```bash
   cp docs/backend-tickets/IMPLEMENTATION_reviews_takedown.py \
      backend/app/routers/admin/reviews_takedown.py
   ```

2. **Run database migration** (SQL in router file)

3. **Register router in main.py:**
   ```python
   from app.routers.admin import reviews_takedown
   app.include_router(reviews_takedown.router, prefix="/api/v1/admin", tags=["Admin Reviews Takedown"])
   ```

4. **Uncomment TODOs** in router file (database queries)

5. **Test with curl** (examples in implementation guide)

**Estimated Time:** 3-4 days with testing  
**Priority:** 🔴 HIGH  

**See:** `IMPLEMENTATION_GUIDE_reviews_takedown.md` for complete instructions

---

**Created by:** Frontend Team  
**For:** Backend Team  
**Date:** November 12, 2025  
**Version:** 1.0  
**Implementation Package:** November 12, 2025
