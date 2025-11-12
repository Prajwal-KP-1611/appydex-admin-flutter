# 🎯 Backend Ticket: Complete Remaining Missing Endpoints

**Priority:** MEDIUM  
**Ticket ID:** BACKEND-COMPLETE-001  
**Date Created:** November 12, 2025  
**Status:** ⏳ PENDING BACKEND IMPLEMENTATION  
**Estimated Effort:** 2-3 days

---

## 📋 Executive Summary

This ticket covers **all remaining missing endpoints** to achieve 100% API coverage:

1. ❌ Background Jobs Management (3 endpoints) - List, Cancel, Delete
2. ❌ Referrals Tracking (1 endpoint) - List referrals
3. ❌ Admin Roles Dynamic Fetching (1 endpoint) - Get available roles
4. ❌ System Management (3 endpoints) - Health, Backup, Restore
5. ❌ Refund Management (3 endpoints) - List, Approve, Reject refunds

**Total:** 11 endpoints across 5 feature areas

---

## 🎯 Section 1: Background Jobs Management

### Current State
- ✅ `GET /api/v1/admin/jobs/{job_id}` - Already requested in Analytics ticket
- ❌ Missing: List, Cancel, Delete endpoints

### 1.1 GET /api/v1/admin/jobs

**Purpose:** List all background jobs for monitoring and management

**Path:** `/api/v1/admin/jobs`  
**Method:** `GET`  
**Permissions:** `jobs:list` or `super_admin`

#### Request

```typescript
{
  page?: number;
  page_size?: number;
  status?: string;        // "pending" | "processing" | "succeeded" | "failed" | "cancelled"
  type?: string;          // "analytics_export" | "bulk_operation" | etc.
  creator_id?: string;    // Filter by admin who created job
  from_date?: string;
  to_date?: string;
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "job-uuid",
      "type": "analytics_export",
      "status": "processing",
      "progress_percent": 65,
      "created_at": "2025-11-12T10:00:00Z",
      "started_at": "2025-11-12T10:00:05Z",
      "creator": {
        "id": "admin-uuid",
        "name": "Admin User"
      },
      "metadata": {
        "report_type": "bookings",
        "from": "2025-10-01",
        "to": "2025-10-31"
      }
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 145,
    "summary": {
      "pending": 5,
      "processing": 2,
      "succeeded": 120,
      "failed": 15,
      "cancelled": 3
    }
  }
}
```

---

### 1.2 POST /api/v1/admin/jobs/{job_id}/cancel

**Purpose:** Cancel a running or pending background job

**Path:** `/api/v1/admin/jobs/{job_id}/cancel`  
**Method:** `POST`  
**Permissions:** `jobs:cancel` or `super_admin` or creator of job  
**Idempotency:** Required

#### Request

```bash
POST /api/v1/admin/jobs/550e8400-e29b-41d4-a716-446655440000/cancel
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: uuid
```

**Body (optional):**
```json
{
  "reason": "No longer needed"
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "job-uuid",
    "status": "cancelled",
    "cancelled_at": "2025-11-12T10:30:00Z",
    "cancelled_by": "admin-uuid"
  }
}
```

#### Error (409 Conflict)

```json
{
  "success": false,
  "error": {
    "code": "CANNOT_CANCEL",
    "message": "Job has already completed",
    "current_status": "succeeded"
  }
}
```

---

### 1.3 DELETE /api/v1/admin/jobs/{job_id}

**Purpose:** Delete completed job record (cleanup)

**Path:** `/api/v1/admin/jobs/{job_id}`  
**Method:** `DELETE`  
**Permissions:** `jobs:delete` or `super_admin` or creator of job  
**Idempotency:** Required

#### Request

```bash
DELETE /api/v1/admin/jobs/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
Idempotency-Key: uuid
```

#### Response (204 No Content)

```json
{
  "success": true
}
```

#### Error (400 Bad Request)

```json
{
  "success": false,
  "error": {
    "code": "CANNOT_DELETE",
    "message": "Can only delete completed (succeeded/failed/cancelled) jobs",
    "current_status": "processing"
  }
}
```

#### Implementation Notes

1. **List Jobs:**
   - Show jobs created by current admin OR admin has `jobs:list_all` permission
   - Default sort: created_at DESC
   - Include summary counts for dashboard

2. **Cancel Job:**
   - Can only cancel pending/processing jobs
   - Send cancellation signal to worker
   - Worker should check cancellation flag regularly
   - Update status to "cancelled" in database

3. **Delete Job:**
   - Can only delete terminal state jobs (succeeded/failed/cancelled)
   - Soft delete or hard delete based on retention policy
   - Also delete associated result files from storage

---

## 🎯 Section 2: Referrals Tracking

### 2.1 GET /api/v1/admin/referrals

**Purpose:** Track referral program performance and payouts

**Path:** `/api/v1/admin/referrals`  
**Method:** `GET`  
**Permissions:** `referrals:list` or `super_admin`

#### Request

```typescript
{
  page?: number;
  page_size?: number;
  status?: string;          // "pending" | "completed" | "expired" | "paid"
  referrer_id?: string;     // Filter by referring user
  referred_id?: string;     // Filter by referred user
  from_date?: string;
  to_date?: string;
  min_amount?: number;      // Minimum referral reward amount
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "referral-uuid",
      "referrer": {
        "id": "user-uuid-1",
        "name": "John Doe",
        "email": "john@example.com",
        "total_referrals": 12,
        "total_earned_cents": 120000
      },
      "referred_user": {
        "id": "user-uuid-2",
        "name": "Jane Smith",
        "email": "jane@example.com",
        "signup_date": "2025-11-01T10:00:00Z",
        "first_booking_date": "2025-11-05T14:00:00Z"
      },
      "referral_code": "JOHN2025",
      "status": "completed",
      "reward_amount_cents": 50000,
      "currency": "INR",
      "credited_at": "2025-11-06T10:00:00Z",
      "payout_status": "paid",
      "created_at": "2025-11-01T10:00:00Z",
      "expires_at": "2025-12-01T10:00:00Z",
      "conditions_met": {
        "signup": true,
        "email_verified": true,
        "first_booking": true,
        "minimum_spend": true
      }
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 450,
    "summary": {
      "pending": 45,
      "completed": 380,
      "expired": 15,
      "paid": 300,
      "total_rewards_cents": 19000000,
      "total_paid_cents": 15000000
    }
  }
}
```

#### Implementation Notes

1. **Data Source:** Query from `referrals` table with joins to `users`
2. **Status Values:**
   - `pending`: Referred user signed up, conditions not met yet
   - `completed`: All conditions met, reward issued
   - `expired`: Referral expired before conditions met
   - `paid`: Reward paid out to referrer

3. **Conditions:**
   - Typically: signup + email verification + first booking + minimum spend
   - Track each condition separately
   - Reward only issued when all conditions met

4. **Performance:**
   - Add index on `(status, created_at)`
   - Cache summary stats for 5 minutes

---

## 🎯 Section 3: Dynamic Roles Fetching

### 3.1 GET /api/v1/admin/roles

**Purpose:** Get list of available roles dynamically (instead of hardcoded frontend)

**Path:** `/api/v1/admin/roles`  
**Method:** `GET`  
**Permissions:** `roles:list` or `super_admin`

#### Request

```bash
GET /api/v1/admin/roles
Authorization: Bearer <admin_jwt_token>
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "super_admin",
      "name": "Super Admin",
      "description": "Full system access with all permissions",
      "permissions": [
        "users:create",
        "users:update",
        "users:delete",
        "users:list",
        "users:view",
        "vendors:verify",
        "vendors:suspend",
        "payments:refund",
        "reviews:moderate",
        "analytics:view",
        "*"
      ],
      "is_system_role": true,
      "can_be_assigned": true,
      "user_count": 5
    },
    {
      "id": "vendor_admin",
      "name": "Vendor Admin",
      "description": "Manage vendors and verify applications",
      "permissions": [
        "vendors:list",
        "vendors:view",
        "vendors:verify",
        "vendors:suspend",
        "services:list",
        "services:view"
      ],
      "is_system_role": true,
      "can_be_assigned": true,
      "user_count": 8
    },
    {
      "id": "support_agent",
      "name": "Support Agent",
      "description": "Handle customer support requests",
      "permissions": [
        "users:list",
        "users:view",
        "users:view_pii",
        "bookings:list",
        "bookings:view",
        "reviews:list",
        "reviews:view"
      ],
      "is_system_role": true,
      "can_be_assigned": true,
      "user_count": 15
    },
    {
      "id": "finance_admin",
      "name": "Finance Admin",
      "description": "Manage payments, refunds, and subscriptions",
      "permissions": [
        "payments:list",
        "payments:view",
        "payments:refund",
        "subscriptions:list",
        "subscriptions:view",
        "analytics:view"
      ],
      "is_system_role": true,
      "can_be_assigned": true,
      "user_count": 3
    },
    {
      "id": "content_moderator",
      "name": "Content Moderator",
      "description": "Moderate reviews and handle takedown requests",
      "permissions": [
        "reviews:list",
        "reviews:view",
        "reviews:moderate",
        "reviews:hide",
        "reviews:remove"
      ],
      "is_system_role": true,
      "can_be_assigned": true,
      "user_count": 6
    }
  ],
  "meta": {
    "total_roles": 5,
    "total_permissions": 47
  }
}
```

#### Implementation Notes

1. **Dynamic Roles:**
   - Fetch from `roles` table instead of hardcoding
   - Allows adding custom roles without frontend changes
   - Include permission list for each role

2. **System Roles:**
   - Mark built-in roles with `is_system_role: true`
   - System roles cannot be deleted/modified
   - Custom roles can be created by super admins

3. **Permission List:**
   - Return flat array of permission strings
   - Frontend uses for checking access
   - Wildcard `*` means all permissions

4. **User Count:**
   - Show how many admins have each role
   - Useful for auditing and planning

---

## 🎯 Section 4: System Management

### 4.1 GET /api/v1/admin/system/health

**Purpose:** System health check for monitoring dashboard

**Path:** `/api/v1/admin/system/health`  
**Method:** `GET`  
**Permissions:** `system:health` or `super_admin`

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2025-11-12T11:00:00Z",
    "version": "2.1.0",
    "environment": "production",
    "services": {
      "database": {
        "status": "healthy",
        "latency_ms": 15,
        "connections": {
          "active": 25,
          "idle": 75,
          "max": 100
        }
      },
      "redis": {
        "status": "healthy",
        "latency_ms": 3,
        "memory_used_mb": 245,
        "memory_max_mb": 1024
      },
      "storage": {
        "status": "healthy",
        "provider": "s3",
        "used_gb": 450,
        "quota_gb": 1000
      },
      "queue": {
        "status": "healthy",
        "pending_jobs": 15,
        "processing_jobs": 5,
        "failed_jobs_24h": 2
      }
    },
    "metrics": {
      "uptime_seconds": 2592000,
      "request_count_24h": 145000,
      "avg_response_time_ms": 125,
      "error_rate_percent": 0.2
    }
  }
}
```

#### Response (503 Service Unavailable) - Unhealthy

```json
{
  "success": false,
  "data": {
    "status": "unhealthy",
    "services": {
      "database": {
        "status": "unhealthy",
        "error": "Connection timeout"
      },
      "redis": {
        "status": "healthy"
      }
    }
  }
}
```

---

### 4.2 POST /api/v1/admin/system/backup

**Purpose:** Trigger manual database backup

**Path:** `/api/v1/admin/system/backup`  
**Method:** `POST`  
**Permissions:** `system:backup` or `super_admin`  
**Idempotency:** Required

#### Request

```json
{
  "backup_type": "full" | "incremental",
  "include_uploads": boolean,
  "description": "Monthly backup before major update"
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "job_id": "job-uuid",
    "status": "pending",
    "estimated_duration_seconds": 600
  }
}
```

Poll job status using `GET /api/v1/admin/jobs/{job_id}`

---

### 4.3 POST /api/v1/admin/system/restore

**Purpose:** Restore from backup (dangerous operation)

**Path:** `/api/v1/admin/system/restore`  
**Method:** `POST`  
**Permissions:** `system:restore` or `super_admin` (requires MFA)  
**Idempotency:** Required

#### Request

```json
{
  "backup_id": "backup-uuid",
  "confirmation_code": "RESTORE-2025-11-12",
  "target_timestamp": "2025-11-12T00:00:00Z"
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "job_id": "job-uuid",
    "status": "pending",
    "warning": "This will replace current data with backup from 2025-11-12T00:00:00Z"
  }
}
```

---

## 🎯 Section 5: Refund Management

### Current State
- ✅ `POST /api/v1/admin/payments/{payment_id}/refund` - Frontend implemented
- ❌ Missing: List refund requests, Approve/Reject workflow

### 5.1 GET /api/v1/admin/refunds

**Purpose:** List all refund requests for approval queue

**Path:** `/api/v1/admin/refunds`  
**Method:** `GET`  
**Permissions:** `refunds:list` or `super_admin`

#### Request

```typescript
{
  page?: number;
  page_size?: number;
  status?: string;        // "pending" | "approved" | "rejected" | "processed"
  user_id?: string;
  vendor_id?: string;
  from_date?: string;
  to_date?: string;
  min_amount?: number;
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": "refund-uuid",
      "refund_number": "RF-2025-001234",
      "status": "pending",
      "payment": {
        "id": "payment-uuid",
        "amount_cents": 500000,
        "currency": "INR",
        "paid_at": "2025-11-01T10:00:00Z"
      },
      "booking": {
        "id": "booking-uuid",
        "booking_number": "BK-2025-005432"
      },
      "user": {
        "id": "user-uuid",
        "name": "John Doe",
        "email": "john@example.com"
      },
      "vendor": {
        "id": "vendor-uuid",
        "name": "ABC Services"
      },
      "requested_amount_cents": 500000,
      "reason": "service_not_provided",
      "description": "Vendor never showed up for scheduled appointment",
      "evidence": [
        {
          "type": "image",
          "url": "https://cdn.../proof.jpg"
        }
      ],
      "requested_at": "2025-11-02T08:00:00Z",
      "requested_by": "user",
      "priority": "high",
      "admin_notes": null
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 45,
    "summary": {
      "pending": 45,
      "approved": 380,
      "rejected": 65,
      "processed": 350,
      "total_amount_pending_cents": 2250000
    }
  }
}
```

---

### 5.2 POST /api/v1/admin/refunds/{refund_id}/approve

**Purpose:** Approve refund request and process refund

**Path:** `/api/v1/admin/refunds/{refund_id}/approve`  
**Method:** `POST`  
**Permissions:** `refunds:approve` or `super_admin`  
**Idempotency:** Required

#### Request

```json
{
  "approved_amount_cents": 500000,
  "reason": "Customer complaint verified. Service was not provided.",
  "admin_notes": "Contacted vendor - confirmed they missed appointment",
  "notify_user": true,
  "notify_vendor": true
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "refund-uuid",
    "status": "approved",
    "approved_at": "2025-11-12T11:00:00Z",
    "approved_by": "admin-uuid",
    "refund_processed": true,
    "transaction_id": "refund-txn-123"
  }
}
```

---

### 5.3 POST /api/v1/admin/refunds/{refund_id}/reject

**Purpose:** Reject refund request with reasoning

**Path:** `/api/v1/admin/refunds/{refund_id}/reject`  
**Method:** `POST`  
**Permissions:** `refunds:approve` or `super_admin`  
**Idempotency:** Required

#### Request

```json
{
  "reason": "Evidence shows service was provided and customer was satisfied at time of completion",
  "admin_notes": "Customer complaint appears to be retaliation",
  "notify_user": true,
  "offer_alternative": "partial_credit"
}
```

#### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "id": "refund-uuid",
    "status": "rejected",
    "rejected_at": "2025-11-12T11:05:00Z",
    "rejected_by": "admin-uuid"
  }
}
```

---

## 📊 Database Requirements

### New Tables

**background_jobs:**
```sql
CREATE TABLE background_jobs (
  id UUID PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  status VARCHAR(20) NOT NULL,
  progress_percent INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL,
  creator_id UUID NOT NULL REFERENCES admin_users(id),
  result JSONB,
  error JSONB,
  metadata JSONB,
  INDEX idx_creator_status (creator_id, status),
  INDEX idx_status_updated (status, updated_at)
);
```

**referrals:**
```sql
CREATE TABLE referrals (
  id UUID PRIMARY KEY,
  referrer_id UUID NOT NULL REFERENCES users(id),
  referred_user_id UUID NOT NULL REFERENCES users(id),
  referral_code VARCHAR(50),
  status VARCHAR(20) NOT NULL,
  reward_amount_cents INT,
  created_at TIMESTAMP NOT NULL,
  expires_at TIMESTAMP,
  credited_at TIMESTAMP,
  INDEX idx_referrer (referrer_id),
  INDEX idx_status (status)
);
```

**refund_requests:**
```sql
CREATE TABLE refund_requests (
  id UUID PRIMARY KEY,
  refund_number VARCHAR(50) UNIQUE NOT NULL,
  payment_id UUID NOT NULL REFERENCES payments(id),
  booking_id UUID NOT NULL REFERENCES bookings(id),
  status VARCHAR(20) NOT NULL,
  requested_amount_cents INT NOT NULL,
  approved_amount_cents INT,
  reason VARCHAR(100),
  description TEXT,
  evidence JSONB,
  requested_at TIMESTAMP NOT NULL,
  approved_at TIMESTAMP,
  approved_by UUID REFERENCES admin_users(id),
  INDEX idx_status (status),
  INDEX idx_payment (payment_id)
);
```

---

## 🔒 Security Considerations

### Rate Limiting
- All endpoints: Standard admin rate limits
- System backup/restore: Extra strict (1 per hour)

### Permissions
- Most endpoints require specific permissions
- System management requires `super_admin` + MFA
- Refund approval requires dual approval for amounts > $1000

### Audit Logging
- Log all admin actions
- Especially: job cancellations, refund approvals, system operations
- Include IP address, user agent, timestamp

---

## 🧪 Testing Requirements

### Priority 1 (Critical)
- [ ] Background jobs list/cancel/delete
- [ ] Refund requests list/approve/reject
- [ ] System health check

### Priority 2 (High)
- [ ] Referrals list and tracking
- [ ] Dynamic roles fetching

### Priority 3 (Optional)
- [ ] System backup/restore (if feature is needed)

---

## 📦 Deliverables

### Code
- [ ] Implement 11 new endpoints
- [ ] Create required database tables
- [ ] Add indexes for performance
- [ ] Implement idempotency for mutating operations
- [ ] Add notification jobs
- [ ] Add audit logging

### Documentation
- [ ] Update OpenAPI spec
- [ ] Add endpoint documentation
- [ ] Document permission requirements

### Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

---

## ✅ Acceptance Criteria

### Background Jobs
- [x] List all jobs with filters
- [x] Cancel running jobs
- [x] Delete completed jobs

### Referrals
- [x] List referrals with status tracking
- [x] Show referral rewards and payouts

### Roles
- [x] Fetch roles dynamically
- [x] Include permission lists

### System
- [x] Health check shows all service statuses
- [x] Backup can be triggered manually

### Refunds
- [x] List refund requests
- [x] Approve/reject with reasoning
- [x] Process refunds automatically on approval

---

**Created by:** Frontend Team  
**For:** Backend Team  
**Date:** November 12, 2025  
**Version:** 1.0
