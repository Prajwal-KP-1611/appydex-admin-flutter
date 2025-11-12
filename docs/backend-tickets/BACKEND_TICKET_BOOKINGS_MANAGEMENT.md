# 🎯 Backend Ticket: Bookings Management Endpoints

**Priority:** HIGH  
**Ticket ID:** BACKEND-BOOKINGS-001  
**Date Created:** November 12, 2025  
**Status:** ⏳ PENDING BACKEND IMPLEMENTATION  
**Estimated Effort:** 2-3 days

---

## 📋 Executive Summary

The admin frontend currently has **0% coverage** for bookings management (0/3 endpoints). This ticket covers the **3 missing endpoints** required for complete bookings administration:

1. ❌ `GET /api/v1/admin/bookings` - List all bookings with pagination and filters
2. ❌ `GET /api/v1/admin/bookings/{booking_id}` - Get booking details
3. ❌ `PATCH /api/v1/admin/bookings/{booking_id}` - Update booking status/details

---

## 🎯 Missing Endpoints

### 1. GET /api/v1/admin/bookings

**Purpose:** List all bookings with comprehensive filtering for admin dashboard

**Path:** `/api/v1/admin/bookings`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `bookings:list` or `super_admin`

#### Request

**Query Parameters:**
```typescript
{
  page?: number;           // Page number (default: 1)
  page_size?: number;      // Items per page (default: 25, max: 100)
  search?: string;         // Search by booking ID, user name, vendor name
  status?: string;         // "pending" | "confirmed" | "in_progress" | "completed" | "cancelled" | "disputed"
  vendor_id?: string;      // Filter by vendor UUID
  user_id?: string;        // Filter by user UUID
  service_id?: string;     // Filter by service UUID
  city?: string;           // Filter by city
  from_date?: string;      // ISO 8601 date - filter bookings from date
  to_date?: string;        // ISO 8601 date - filter bookings to date
  sort_by?: string;        // "created_at" | "scheduled_at" | "amount" (default: "created_at")
  sort_order?: string;     // "asc" | "desc" (default: "desc")
}
```

**Example Request:**
```bash
GET /api/v1/admin/bookings?page=1&page_size=25&status=pending&from_date=2025-11-01T00:00:00Z
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "booking-uuid-123",
      "booking_number": "BK-2025-001234",
      "status": "pending",
      "user": {
        "id": "user-uuid",
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+919876543210"
      },
      "vendor": {
        "id": "vendor-uuid",
        "name": "ABC Services",
        "display_name": "ABC Professional Services"
      },
      "service": {
        "id": "service-uuid",
        "name": "Plumbing Repair",
        "category": "Home Services"
      },
      "scheduled_at": "2025-11-15T10:00:00Z",
      "address": {
        "street": "123 Main St",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001",
        "landmark": "Near City Mall"
      },
      "amount_cents": 250000,
      "currency": "INR",
      "payment_status": "pending",
      "payment_method": "upi",
      "created_at": "2025-11-12T08:30:00Z",
      "updated_at": "2025-11-12T08:30:00Z",
      "notes": "Urgent - Leaking pipe in kitchen",
      "has_dispute": false,
      "dispute_status": null,
      "cancellation_reason": null,
      "cancelled_by": null,
      "cancelled_at": null
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 1450,
    "total_pages": 58,
    "has_next": true,
    "has_prev": false
  }
}
```

**Error Responses:**

**400 Bad Request - Invalid Parameters:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid query parameters",
    "details": {
      "status": ["Must be one of: pending, confirmed, in_progress, completed, cancelled, disputed"],
      "page_size": ["Must be between 1 and 100"]
    }
  }
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to list bookings",
    "required_permission": "bookings:list"
  }
}
```

#### Implementation Notes

1. **Data Source:** Query from `bookings` table with joins:
   - `users` table for user info
   - `vendors` table for vendor info
   - `services` table for service info
   - `addresses` table for location info
   - `disputes` table for dispute status

2. **Pagination:**
   - Use LIMIT/OFFSET or cursor-based pagination
   - Default page_size: 25
   - Maximum page_size: 100
   - Return total count for UI pagination

3. **Filters:**
   - Apply WHERE clauses for all optional filters
   - Use ILIKE for search (case-insensitive)
   - Search fields: booking_number, user.name, vendor.name
   - Date filters on `scheduled_at` field

4. **Performance:**
   - Add indexes on frequently filtered columns
   - Consider materialized view for dashboard queries
   - Cache count queries for 1 minute

5. **Sorting:**
   - Support sorting by created_at, scheduled_at, amount
   - Default: created_at DESC (newest first)

---

### 2. GET /api/v1/admin/bookings/{booking_id}

**Purpose:** Get detailed information about a specific booking

**Path:** `/api/v1/admin/bookings/{booking_id}`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `bookings:view` or `super_admin`

#### Request

**Path Parameters:**
- `booking_id` (string, required) - UUID of the booking

**Example Request:**
```bash
GET /api/v1/admin/bookings/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "booking-uuid-123",
    "booking_number": "BK-2025-001234",
    "status": "confirmed",
    "status_history": [
      {
        "status": "pending",
        "changed_at": "2025-11-12T08:30:00Z",
        "changed_by": "system"
      },
      {
        "status": "confirmed",
        "changed_at": "2025-11-12T09:15:00Z",
        "changed_by": "vendor-uuid"
      }
    ],
    "user": {
      "id": "user-uuid",
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+919876543210",
      "profile_image": "https://cdn.../user.jpg",
      "total_bookings": 12,
      "trust_score": 85
    },
    "vendor": {
      "id": "vendor-uuid",
      "name": "ABC Services",
      "display_name": "ABC Professional Services",
      "email": "vendor@abc.com",
      "phone": "+919876543000",
      "logo": "https://cdn.../vendor.jpg",
      "rating": 4.5,
      "total_bookings": 450,
      "verification_status": "verified"
    },
    "service": {
      "id": "service-uuid",
      "name": "Plumbing Repair",
      "category": "Home Services",
      "subcategory": "Plumbing",
      "description": "Professional plumbing repair services",
      "pricing_type": "fixed",
      "base_price_cents": 250000
    },
    "scheduled_at": "2025-11-15T10:00:00Z",
    "estimated_duration_minutes": 120,
    "address": {
      "street": "123 Main St",
      "apartment": "Apt 4B",
      "city": "Mumbai",
      "state": "Maharashtra",
      "pincode": "400001",
      "landmark": "Near City Mall",
      "coordinates": {
        "lat": 19.0760,
        "lng": 72.8777
      }
    },
    "pricing": {
      "base_amount_cents": 250000,
      "tax_cents": 45000,
      "platform_fee_cents": 25000,
      "discount_cents": 0,
      "total_amount_cents": 320000,
      "currency": "INR",
      "breakdown": [
        {
          "description": "Service charge",
          "amount_cents": 250000
        },
        {
          "description": "GST (18%)",
          "amount_cents": 45000
        },
        {
          "description": "Platform fee",
          "amount_cents": 25000
        }
      ]
    },
    "payment": {
      "status": "completed",
      "method": "upi",
      "transaction_id": "TXN-123456",
      "paid_at": "2025-11-12T08:35:00Z",
      "refund_status": null,
      "refunded_amount_cents": 0
    },
    "created_at": "2025-11-12T08:30:00Z",
    "updated_at": "2025-11-12T09:15:00Z",
    "notes": "Urgent - Leaking pipe in kitchen",
    "admin_notes": "Customer is premium user",
    "customer_requirements": [
      "Bring replacement parts",
      "Call before arrival"
    ],
    "images": [
      {
        "url": "https://cdn.../problem1.jpg",
        "uploaded_at": "2025-11-12T08:28:00Z",
        "uploaded_by": "user"
      }
    ],
    "dispute": null,
    "cancellation": null,
    "completion": null,
    "review": null,
    "timeline": [
      {
        "event": "booking_created",
        "timestamp": "2025-11-12T08:30:00Z",
        "actor": "user",
        "details": "Booking created by customer"
      },
      {
        "event": "payment_completed",
        "timestamp": "2025-11-12T08:35:00Z",
        "actor": "system",
        "details": "Payment successful via UPI"
      },
      {
        "event": "booking_confirmed",
        "timestamp": "2025-11-12T09:15:00Z",
        "actor": "vendor",
        "details": "Vendor confirmed the booking"
      }
    ]
  }
}
```

**Success Response (200 OK) - Booking with Dispute:**
```json
{
  "success": true,
  "data": {
    "id": "booking-uuid-456",
    "booking_number": "BK-2025-001235",
    "status": "disputed",
    "dispute": {
      "id": "dispute-uuid",
      "status": "open",
      "raised_by": "user",
      "reason": "service_not_provided",
      "description": "Vendor didn't show up",
      "evidence": [
        {
          "type": "image",
          "url": "https://cdn.../evidence.jpg"
        }
      ],
      "created_at": "2025-11-13T14:00:00Z",
      "resolution_notes": null,
      "resolved_at": null,
      "resolved_by": null
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
    "code": "BOOKING_NOT_FOUND",
    "message": "Booking not found",
    "booking_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to view this booking",
    "required_permission": "bookings:view"
  }
}
```

#### Implementation Notes

1. **Data Assembly:**
   - Fetch booking with all related entities
   - Include status history for audit trail
   - Include timeline for chronological events
   - Fetch user and vendor summary data

2. **Performance:**
   - Use eager loading to avoid N+1 queries
   - Consider caching for recently viewed bookings (1 minute TTL)

3. **Privacy:**
   - Mask sensitive user data based on admin permissions
   - Full PII access requires `users:view_pii` permission

---

### 3. PATCH /api/v1/admin/bookings/{booking_id}

**Purpose:** Update booking status, add admin notes, or make administrative changes

**Path:** `/api/v1/admin/bookings/{booking_id}`  
**Method:** `PATCH`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `bookings:update` or `super_admin`  
**Idempotency:** Required - `Idempotency-Key` header

#### Request

**Path Parameters:**
- `booking_id` (string, required) - UUID of the booking

**Headers:**
```
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

**Body:**
```typescript
{
  status?: string;              // "confirmed" | "cancelled" | "completed" (limited transitions)
  admin_notes?: string;         // Internal notes visible only to admins
  cancellation_reason?: string; // Required if status = "cancelled"
  force_refund?: boolean;       // Force full refund on cancellation (default: false)
  notify_user?: boolean;        // Send notification to user (default: true)
  notify_vendor?: boolean;      // Send notification to vendor (default: true)
}
```

**Example Request - Add Admin Notes:**
```bash
PATCH /api/v1/admin/bookings/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440001
Content-Type: application/json

{
  "admin_notes": "Customer requested priority service. Vendor has been notified."
}
```

**Example Request - Cancel Booking:**
```bash
PATCH /api/v1/admin/bookings/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440002
Content-Type: application/json

{
  "status": "cancelled",
  "cancellation_reason": "Customer requested cancellation after multiple reschedules",
  "force_refund": true,
  "notify_user": true,
  "notify_vendor": true
}
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "booking-uuid-123",
    "booking_number": "BK-2025-001234",
    "status": "cancelled",
    "admin_notes": "Customer requested cancellation after multiple reschedules",
    "cancellation": {
      "reason": "Customer requested cancellation after multiple reschedules",
      "cancelled_by": "admin-uuid",
      "cancelled_at": "2025-11-12T10:30:00Z",
      "refund_issued": true,
      "refund_amount_cents": 320000
    },
    "updated_at": "2025-11-12T10:30:00Z",
    "updated_by": "admin-uuid"
  }
}
```

**Error Responses:**

**400 Bad Request - Invalid Status Transition:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_STATUS_TRANSITION",
    "message": "Cannot change booking from 'completed' to 'pending'",
    "current_status": "completed",
    "requested_status": "pending",
    "allowed_transitions": ["disputed"]
  }
}
```

**400 Bad Request - Missing Required Field:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "cancellation_reason": ["Required when status is 'cancelled'"]
    }
  }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": {
    "code": "BOOKING_NOT_FOUND",
    "message": "Booking not found",
    "booking_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to update bookings",
    "required_permission": "bookings:update"
  }
}
```

**409 Conflict - Idempotency Key Reused:**
```json
{
  "success": false,
  "error": {
    "code": "IDEMPOTENCY_CONFLICT",
    "message": "Operation already completed with different parameters",
    "idempotency_key": "550e8400-e29b-41d4-a716-446655440002"
  }
}
```

#### Valid Status Transitions

| Current Status | Allowed Transitions | Notes |
|----------------|-------------------|-------|
| `pending` | `confirmed`, `cancelled` | Initial state |
| `confirmed` | `in_progress`, `cancelled` | Vendor can start work |
| `in_progress` | `completed`, `cancelled`, `disputed` | Work ongoing |
| `completed` | `disputed` | Terminal state |
| `cancelled` | None | Terminal state |
| `disputed` | `completed`, `cancelled` | After resolution |

#### Implementation Notes

1. **Idempotency:**
   - Store idempotency key with operation result
   - TTL: 24 hours
   - Return same response for duplicate requests
   - Return 409 if key exists with different parameters

2. **Status Transitions:**
   - Validate allowed transitions
   - Create status_history entry for each change
   - Add timeline event for audit

3. **Cancellation Logic:**
   - Calculate refund amount based on policy
   - If `force_refund: true`, issue full refund
   - Create refund record
   - Update payment status

4. **Notifications:**
   - Queue notification jobs if notify flags are true
   - Use background job for email/SMS/push
   - Include cancellation reason in notification

5. **Audit Trail:**
   - Log all admin changes to audit_logs table
   - Include: admin_id, booking_id, action, before/after state
   - Store IP address and user agent

---

## 🔒 Security & Validation

### Authentication
- All endpoints require valid JWT Bearer token
- Token must not be expired
- Token must have required permissions

### Authorization (RBAC)

| Endpoint | Required Permission | Alternative |
|----------|-------------------|-------------|
| `GET /admin/bookings` | `bookings:list` | `super_admin` |
| `GET /admin/bookings/{id}` | `bookings:view` | `super_admin` |
| `PATCH /admin/bookings/{id}` | `bookings:update` | `super_admin` |

**Additional Permission for PII:**
- Full user details require `users:view_pii`
- Without it, mask: email (partial), phone (partial), address (partial)

### Input Validation

**Status Field:**
- Must be one of allowed values
- Must follow valid transition rules
- Cannot bypass workflow (e.g., pending → completed)

**Cancellation:**
- `cancellation_reason` required if status = "cancelled"
- Reason must be 10-500 characters
- Cannot cancel already completed/cancelled bookings

**Admin Notes:**
- Optional, max 2000 characters
- Stored separately from user-visible notes

**Pagination:**
- page: min 1
- page_size: min 1, max 100
- Default: page=1, page_size=25

### Rate Limiting

- List endpoint: 60 requests per minute per admin
- Detail endpoint: 120 requests per minute per admin
- Update endpoint: 30 requests per minute per admin
- Return `429 Too Many Requests` with `Retry-After` header

---

## 📊 Database Indexes

**Required Indexes for Performance:**

```sql
-- Bookings list query optimization
CREATE INDEX idx_bookings_status_created ON bookings(status, created_at DESC);
CREATE INDEX idx_bookings_scheduled ON bookings(scheduled_at);
CREATE INDEX idx_bookings_vendor ON bookings(vendor_id, created_at DESC);
CREATE INDEX idx_bookings_user ON bookings(user_id, created_at DESC);
CREATE INDEX idx_bookings_service ON bookings(service_id, created_at DESC);

-- Search optimization
CREATE INDEX idx_bookings_number ON bookings(booking_number);
CREATE INDEX idx_bookings_search ON bookings USING gin(to_tsvector('english', booking_number));

-- Disputes
CREATE INDEX idx_bookings_has_dispute ON bookings(has_dispute) WHERE has_dispute = true;
```

---

## 🧪 Testing Requirements

### Unit Tests
- [ ] List bookings with pagination
- [ ] List bookings with filters (status, vendor_id, user_id)
- [ ] Search by booking number, user name, vendor name
- [ ] Get booking detail with all related data
- [ ] Update booking status (valid transitions)
- [ ] Reject invalid status transitions
- [ ] Add admin notes
- [ ] Cancel booking with refund
- [ ] Idempotency key validation

### Integration Tests
- [ ] List bookings returns correct pagination meta
- [ ] Filter by multiple criteria
- [ ] Sort by different fields (created_at, scheduled_at, amount)
- [ ] Get booking with complete timeline
- [ ] Update booking and verify notification sent
- [ ] Cancel booking and verify refund issued
- [ ] Duplicate request with same idempotency key returns same response

### Performance Tests
- [ ] List query performance with 1M+ bookings
- [ ] Detail query with complex joins
- [ ] Concurrent updates to same booking (locking)

### Manual Testing Checklist
- [ ] Test pagination (page 1, 2, 3, last)
- [ ] Test all status filters
- [ ] Test search functionality
- [ ] Test date range filters
- [ ] Test sorting (asc/desc, different fields)
- [ ] View booking with dispute
- [ ] View booking with cancellation
- [ ] Update admin notes
- [ ] Cancel booking
- [ ] Test all status transitions
- [ ] Test invalid transitions (should fail)
- [ ] Test idempotency (duplicate request)

---

## 📦 Deliverables

### Code
- [ ] Implement `GET /api/v1/admin/bookings`
- [ ] Implement `GET /api/v1/admin/bookings/{booking_id}`
- [ ] Implement `PATCH /api/v1/admin/bookings/{booking_id}`
- [ ] Add database indexes
- [ ] Implement status transition validation
- [ ] Implement cancellation/refund logic
- [ ] Add notification jobs
- [ ] Add audit logging

### Documentation
- [ ] API documentation in OpenAPI spec
- [ ] Update `/openapi/v1.json` with new endpoints
- [ ] Document status transition rules
- [ ] Document refund policy

### Testing
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] Performance tests
- [ ] Load testing report

---

## 🚀 Deployment Plan

### Prerequisites
- Database migrations for indexes
- Notification service configured
- Refund processing service ready

### Rollout Steps
1. Deploy database migrations
2. Deploy API endpoints (feature flag: OFF)
3. Test in staging environment
4. Enable feature flag in production
5. Monitor error rates and performance
6. Roll out to all admins

### Monitoring
- Track endpoint response times
- Monitor status transition errors
- Track refund processing success rate
- Set up alerts for:
  - Response time > 3s
  - Error rate > 1%
  - Failed refunds

---

## 📞 Questions for Backend Team

1. **Refund Policy:** What's the refund calculation logic? Full refund, partial based on timing?
2. **Notification Service:** Which notification service to integrate? (Email, SMS, Push)
3. **Status Workflow:** Any additional business rules for status transitions?
4. **Dispute Resolution:** How do disputed bookings get resolved? Manual admin action?
5. **Data Retention:** How long should we keep cancelled booking data?

---

## ✅ Acceptance Criteria

### Functional
- [x] List bookings with pagination works
- [x] All filters apply correctly (status, vendor, user, date range)
- [x] Search finds bookings by number/name
- [x] Detail view shows complete booking information
- [x] Admin can add notes
- [x] Admin can cancel bookings
- [x] Refunds are processed correctly
- [x] Status transitions follow business rules
- [x] Invalid transitions are rejected

### Performance
- [x] List query < 1s for 100K bookings
- [x] Detail query < 500ms
- [x] Update operation < 1s including notifications

### Security
- [x] RBAC enforced on all endpoints
- [x] Idempotency prevents duplicate operations
- [x] PII is masked without proper permissions
- [x] Audit logs capture all admin actions

---

## 📚 Related Documentation

- Frontend Bookings Models: `lib/models/booking.dart` (to be created)
- Frontend Bookings Repository: `lib/repositories/booking_repo.dart` (to be created)
- Frontend API Alignment: `docs/api/FRONTEND_BACKEND_API_ALIGNMENT.md`

---

**Created by:** Frontend Team  
**For:** Backend Team  
**Date:** November 12, 2025  
**Version:** 1.0
