# 🎫 Backend API Ticket: Comprehensive End-User Management & Dispute Resolution

**Ticket ID:** `BACKEND-EU-001`  
**Priority:** High (P1)  
**Category:** End-User Management & Customer Support  
**Requested By:** Frontend Team  
**Date:** November 9, 2025  

---

## 📋 EXECUTIVE SUMMARY

Request for comprehensive backend API endpoints to support end-user (customer) management with full activity tracking, dispute/complaint management, and customer support workflows in the admin panel.

**Current State:** Basic user CRUD operations exist  
**Desired State:** Full end-user lifecycle management with dispute resolution system

---

## 🎯 BUSINESS REQUIREMENTS

### 1. **End-User Management Scope**
The Users section in admin panel should focus **exclusively on end-users** (customers who book services), NOT:
- ❌ Admin users (already in "Admin Users" section)
- ❌ Vendors (already in "Vendors" section)

### 2. **Core Objectives**
1. ✅ View complete end-user profile with all platform activities
2. ✅ Track user engagement metrics (bookings, reviews, disputes)
3. ✅ Manage customer complaints and disputes
4. ✅ Monitor user behavior patterns
5. ✅ Support customer service workflows
6. ✅ Handle account management (suspend, reactivate, anonymize)

---

## 📊 REQUIRED API ENDPOINTS

### **Category A: Enhanced User Profile (P0 - Critical)**

#### 1. Get User Detail with Full Activity
```
GET /api/v1/admin/users/{user_id}
```

**Response Structure:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "customer@example.com",
    "phone": "+919876543210",
    "name": "John Doe",
    "profile_picture_url": "https://...",
    "is_active": true,
    "is_suspended": false,
    "suspension_reason": null,
    "email_verified": true,
    "phone_verified": true,
    "account_status": "active",  // active|suspended|banned|deleted
    "created_at": "2025-01-15T10:00:00Z",
    "last_login_at": "2025-11-09T08:30:00Z",
    "last_active_at": "2025-11-09T12:45:00Z",
    
    // Activity Summary
    "activity_summary": {
      "total_bookings": 15,
      "completed_bookings": 12,
      "cancelled_bookings": 2,
      "pending_bookings": 1,
      "total_spent": 250000,  // in paise
      "total_reviews": 10,
      "average_rating_given": 4.5,
      "total_disputes": 2,
      "open_disputes": 0,
      "wallet_balance": 5000,  // in paise
      "loyalty_points": 150
    },
    
    // Verification Status
    "verification": {
      "email_verified_at": "2025-01-15T10:30:00Z",
      "phone_verified_at": "2025-01-15T11:00:00Z",
      "identity_verified": false,
      "identity_document_type": null,
      "identity_verified_at": null
    },
    
    // Platform Engagement
    "engagement": {
      "total_logins": 45,
      "days_since_registration": 298,
      "days_since_last_activity": 0,
      "favorite_categories": ["photography", "catering"],
      "preferred_payment_method": "upi",
      "device_type": "mobile"  // mobile|web|app
    },
    
    // Risk Indicators
    "risk_indicators": {
      "has_payment_failures": false,
      "failed_payment_count": 0,
      "has_disputes": true,
      "dispute_win_rate": 0.5,  // 0-1
      "cancellation_rate": 0.13,  // 0-1
      "trust_score": 85  // 0-100
    }
  }
}
```

**Business Logic:**
- Calculate trust_score based on: booking completion rate, payment success rate, dispute history, review ratings
- Flag users with high cancellation rates (>30%) or multiple disputes
- Track last_active_at from any API interaction

---

#### 2. Get User Bookings History
```
GET /api/v1/admin/users/{user_id}/bookings
```

**Query Parameters:**
- `page` (int, default: 1)
- `page_size` (int, default: 20, max: 100)
- `status` (enum: pending|confirmed|completed|cancelled|refunded)
- `from_date` (ISO 8601)
- `to_date` (ISO 8601)
- `sort` (enum: created_at|booking_date|amount, default: created_at)
- `order` (enum: asc|desc, default: desc)

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "bkg_123",
        "booking_reference": "BKG-2025-0001",
        "service_id": "svc_456",
        "service_name": "Wedding Photography",
        "vendor_id": 10,
        "vendor_name": "ABC Studios",
        "status": "completed",
        "booking_date": "2025-02-14T10:00:00Z",
        "amount": 50000,
        "payment_status": "paid",
        "payment_method": "upi",
        "has_review": true,
        "review_rating": 5,
        "has_dispute": false,
        "created_at": "2025-01-20T15:30:00Z",
        "completed_at": "2025-02-14T18:00:00Z"
      }
    ],
    "total": 15,
    "page": 1,
    "page_size": 20,
    "total_pages": 1
  }
}
```

---

#### 3. Get User Reviews
```
GET /api/v1/admin/users/{user_id}/reviews
```

**Query Parameters:**
- `page`, `page_size`
- `rating` (filter: 1-5)
- `has_response` (bool)

**Response:**
```json
{
  "items": [
    {
      "id": 1,
      "booking_id": "bkg_123",
      "service_id": "svc_456",
      "service_name": "Wedding Photography",
      "vendor_id": 10,
      "vendor_name": "ABC Studios",
      "rating": 5,
      "title": "Excellent service!",
      "comment": "Very professional and creative...",
      "photos": ["url1", "url2"],
      "helpful_count": 12,
      "vendor_response": "Thank you for your kind words!",
      "vendor_responded_at": "2025-02-15T10:00:00Z",
      "is_verified": true,  // verified purchase
      "created_at": "2025-02-14T19:00:00Z"
    }
  ],
  "total": 10,
  "page": 1
}
```

---

#### 4. Get User Payment History
```
GET /api/v1/admin/users/{user_id}/payments
```

**Response:**
```json
{
  "items": [
    {
      "id": "pay_789",
      "booking_id": "bkg_123",
      "amount": 50000,
      "payment_method": "upi",
      "payment_gateway": "razorpay",
      "gateway_transaction_id": "pay_xxx",
      "status": "success",  // success|failed|pending|refunded
      "failure_reason": null,
      "refund_amount": 0,
      "refund_reason": null,
      "created_at": "2025-01-20T15:35:00Z",
      "completed_at": "2025-01-20T15:35:30Z"
    }
  ],
  "total": 15,
  "summary": {
    "total_paid": 250000,
    "total_refunded": 10000,
    "success_rate": 0.93,  // 0-1
    "failed_count": 1
  }
}
```

---

### **Category B: Dispute Management (P0 - Critical)**

#### 5. List User Disputes/Complaints
```
GET /api/v1/admin/users/{user_id}/disputes
```

**Query Parameters:**
- `page`, `page_size`
- `status` (enum: open|in_progress|resolved|closed|rejected)
- `type` (enum: booking_issue|payment_issue|service_quality|vendor_behavior|refund_request|other)
- `priority` (enum: low|medium|high|urgent)

**Response:**
```json
{
  "items": [
    {
      "id": 1,
      "dispute_reference": "DSP-2025-0001",
      "type": "service_quality",
      "category": "vendor_no_show",
      "status": "in_progress",
      "priority": "high",
      "subject": "Vendor did not show up",
      "description": "Booked photographer for wedding but vendor never arrived...",
      "booking_id": "bkg_123",
      "booking_reference": "BKG-2025-0001",
      "vendor_id": 10,
      "vendor_name": "ABC Studios",
      "amount_disputed": 50000,
      "refund_requested": true,
      "refund_amount": 50000,
      "evidence": [
        {
          "type": "image",
          "url": "https://...",
          "description": "Screenshot of messages"
        }
      ],
      "created_at": "2025-02-14T11:00:00Z",
      "updated_at": "2025-02-15T10:00:00Z",
      "assigned_to": 2,  // admin user ID
      "assigned_to_name": "Support Admin",
      "resolution_deadline": "2025-02-17T23:59:59Z",
      "vendor_response": "We had a family emergency...",
      "vendor_responded_at": "2025-02-14T15:00:00Z",
      "admin_notes": "Vendor provided proof of emergency. Negotiate partial refund.",
      "resolution": null,
      "resolved_at": null,
      "resolution_type": null  // full_refund|partial_refund|no_refund|service_redo
    }
  ],
  "total": 2,
  "summary": {
    "open": 0,
    "in_progress": 1,
    "resolved": 1,
    "avg_resolution_time_hours": 24.5,
    "user_win_rate": 0.5
  }
}
```

---

#### 6. Get Single Dispute Detail
```
GET /api/v1/admin/disputes/{dispute_id}
```

**Response:** Full dispute object with:
- Complete timeline/activity log
- All messages between user, vendor, admin
- All evidence attachments
- Resolution history
- Related bookings/payments

---

#### 7. Update Dispute Status
```
PATCH /api/v1/admin/disputes/{dispute_id}
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "status": "resolved",
  "resolution_type": "partial_refund",
  "refund_amount": 25000,
  "admin_notes": "Vendor provided valid reason. Agreed to 50% refund.",
  "resolution_details": "Vendor had family emergency. User accepted partial refund.",
  "notify_user": true,
  "notify_vendor": true
}
```

---

#### 8. Add Dispute Message/Note
```
POST /api/v1/admin/disputes/{dispute_id}/messages
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "message": "We've contacted the vendor. Response expected within 24 hours.",
  "is_internal": false,  // false = visible to user, true = admin-only note
  "attachments": ["url1", "url2"]
}
```

---

#### 9. Assign Dispute to Admin
```
POST /api/v1/admin/disputes/{dispute_id}/assign
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "admin_user_id": 2,
  "notes": "Assigning to senior support for urgent handling"
}
```

---

### **Category C: User Activity Tracking (P1 - High)**

#### 10. Get User Activity Log
```
GET /api/v1/admin/users/{user_id}/activity
```

**Query Parameters:**
- `page`, `page_size`
- `activity_type` (enum: login|logout|booking_created|payment|review|dispute|profile_update)
- `from_date`, `to_date`

**Response:**
```json
{
  "items": [
    {
      "id": 1,
      "activity_type": "booking_created",
      "description": "Created booking BKG-2025-0001 for Wedding Photography",
      "metadata": {
        "booking_id": "bkg_123",
        "service_name": "Wedding Photography",
        "amount": 50000
      },
      "ip_address": "192.168.1.1",
      "user_agent": "Mozilla/5.0...",
      "device_type": "mobile",
      "location": "Mumbai, Maharashtra",
      "created_at": "2025-01-20T15:30:00Z"
    }
  ],
  "total": 150
}
```

---

#### 11. Get User Sessions
```
GET /api/v1/admin/users/{user_id}/sessions
```

**Response:**
```json
{
  "active_sessions": [
    {
      "session_id": "sess_abc",
      "device_type": "mobile",
      "device_name": "iPhone 14",
      "browser": "Safari 17",
      "ip_address": "192.168.1.1",
      "location": "Mumbai, Maharashtra",
      "last_activity": "2025-11-09T12:45:00Z",
      "created_at": "2025-11-09T08:00:00Z"
    }
  ],
  "recent_logins": [
    {
      "login_at": "2025-11-09T08:00:00Z",
      "ip_address": "192.168.1.1",
      "device_type": "mobile",
      "location": "Mumbai, Maharashtra",
      "success": true
    }
  ]
}
```

---

### **Category D: User Management Actions (P1 - High)**

#### 12. Suspend User with Reason
```
POST /api/v1/admin/users/{user_id}/suspend
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "reason": "Multiple payment failures and disputes",
  "duration_days": 30,  // null for indefinite
  "notify_user": true,
  "internal_notes": "User has 3 failed payments and 2 disputes in last month"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": 1,
    "status": "suspended",
    "suspended_until": "2025-12-09T23:59:59Z",
    "can_reactivate_at": "2025-12-09T00:00:00Z"
  }
}
```

---

#### 13. Reactivate User
```
POST /api/v1/admin/users/{user_id}/reactivate
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "notes": "User contacted support and resolved payment issues",
  "notify_user": true
}
```

---

#### 14. Force Logout (Kill All Sessions)
```
POST /api/v1/admin/users/{user_id}/logout-all
Headers: Idempotency-Key: <uuid>
```

**Use Case:** Security concerns, suspicious activity

---

#### 15. Update User Trust Score
```
PATCH /api/v1/admin/users/{user_id}/trust-score
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "score": 50,  // 0-100
  "reason": "Multiple failed payments and disputes",
  "apply_restrictions": true  // auto-apply limits based on score
}
```

---

### **Category E: Bulk Operations (P2 - Medium)**

#### 16. Export Users Data
```
POST /api/v1/admin/users/export
```

**Request Body:**
```json
{
  "format": "csv",  // csv|xlsx|json
  "filters": {
    "status": "active",
    "registered_after": "2025-01-01",
    "has_bookings": true
  },
  "fields": ["id", "email", "name", "total_bookings", "total_spent", "created_at"]
}
```

---

#### 17. Send Notification to User
```
POST /api/v1/admin/users/{user_id}/notify
Headers: Idempotency-Key: <uuid>
```

**Request Body:**
```json
{
  "channel": "email",  // email|sms|push|in_app
  "subject": "Important Update",
  "message": "Your dispute has been resolved...",
  "priority": "high",
  "action_url": "https://app.appydex.com/bookings/123"
}
```

---

### **Category F: Dispute System - List All Disputes (P0)**

#### 18. List All Disputes (Global View)
```
GET /api/v1/admin/disputes
```

**Query Parameters:**
- `page`, `page_size`
- `status`, `type`, `priority`
- `assigned_to` (admin user ID)
- `unassigned` (bool)
- `from_date`, `to_date`
- `sort` (created_at|priority|deadline)

**Response:** Paginated list of all disputes across all users

---

## 🎨 FRONTEND INTEGRATION PLAN

### **Enhanced Users Screen Structure:**

```
Users (End-users) Section
├── User List View
│   ├── Search & Filters (email, phone, name, status, trust score)
│   ├── User Cards with:
│   │   ├── Profile info
│   │   ├── Activity summary
│   │   ├── Trust score indicator
│   │   ├── Quick actions (suspend, view details)
│   └── Pagination
│
└── User Detail View (Click on user)
    ├── Profile Tab
    │   ├── Personal info
    │   ├── Verification status
    │   ├── Account status & actions
    │   └── Risk indicators
    │
    ├── Activity Tab
    │   ├── Activity summary cards
    │   ├── Recent activity timeline
    │   └── Session management
    │
    ├── Bookings Tab
    │   ├── Booking history table
    │   ├── Filters (status, date range)
    │   └── Booking summary stats
    │
    ├── Payments Tab
    │   ├── Payment history
    │   ├── Payment summary
    │   └── Failed payment alerts
    │
    ├── Reviews Tab
    │   ├── All reviews by user
    │   ├── Average rating
    │   └── Review moderation
    │
    └── Disputes Tab ⭐
        ├── Active disputes list
        ├── Dispute history
        ├── Quick resolution actions
        └── Timeline view

Disputes Management (New Section)
├── Disputes Dashboard
│   ├── Priority queue (urgent first)
│   ├── My Assignments
│   ├── Unassigned disputes
│   └── Statistics
│
└── Dispute Detail View
    ├── Dispute Info
    ├── User & Vendor details
    ├── Related booking
    ├── Evidence gallery
    ├── Message thread
    ├── Admin actions:
    │   ├── Update status
    │   ├── Process refund
    │   ├── Add notes
    │   ├── Assign/reassign
    │   └── Close dispute
    └── Resolution form
```

---

## 📈 DATA MODELS REQUIRED

### 1. EndUser (Enhanced)
```dart
class EndUser {
  final int id;
  final String email;
  final String? phone;
  final String? name;
  final String? profilePictureUrl;
  final bool isActive;
  final bool isSuspended;
  final String? suspensionReason;
  final bool emailVerified;
  final bool phoneVerified;
  final String accountStatus;  // active|suspended|banned
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  
  final UserActivitySummary activitySummary;
  final UserVerification verification;
  final UserEngagement engagement;
  final UserRiskIndicators riskIndicators;
}
```

### 2. Dispute
```dart
class Dispute {
  final int id;
  final String disputeReference;
  final DisputeType type;
  final String category;
  final DisputeStatus status;
  final DisputePriority priority;
  final String subject;
  final String description;
  final String bookingId;
  final int userId;
  final String userName;
  final int vendorId;
  final String vendorName;
  final int amountDisputed;
  final bool refundRequested;
  final int? refundAmount;
  final List<DisputeEvidence> evidence;
  final int? assignedTo;
  final String? assignedToName;
  final DateTime? resolutionDeadline;
  final String? vendorResponse;
  final String? adminNotes;
  final String? resolution;
  final DisputeResolutionType? resolutionType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
}
```

### 3. DisputeMessage
```dart
class DisputeMessage {
  final int id;
  final int disputeId;
  final String message;
  final MessageSender sender;  // user|vendor|admin
  final int senderId;
  final String senderName;
  final bool isInternal;  // admin-only notes
  final List<String> attachments;
  final DateTime createdAt;
}
```

---

## 🔒 SECURITY & PERMISSIONS

### Required Permissions:
- `users.view` - View user list
- `users.view_detail` - View full user profile
- `users.manage` - Suspend/reactivate users
- `users.anonymize` - GDPR data deletion
- `disputes.view` - View disputes
- `disputes.manage` - Update dispute status, assign, resolve
- `disputes.refund` - Approve refunds

### Audit Logging:
All admin actions must be logged:
- User profile views
- Status changes (suspend, reactivate)
- Dispute assignments
- Dispute resolutions
- Refund approvals

---

## 📊 PERFORMANCE REQUIREMENTS

1. **Response Times:**
   - List endpoints: < 500ms for 20 items
   - Detail endpoints: < 300ms
   - Search: < 800ms

2. **Pagination:**
   - Default: 20 items per page
   - Max: 100 items per page

3. **Caching:**
   - User activity summaries: 5 minutes
   - Dispute counts: 1 minute
   - User profiles: 2 minutes

---

## 🧪 TESTING REQUIREMENTS

### Test Scenarios:
1. ✅ List users with various filters
2. ✅ View user detail with all related data
3. ✅ Suspend user → verify bookings blocked
4. ✅ Create dispute → verify workflow
5. ✅ Resolve dispute → verify notifications
6. ✅ Process refund → verify payment updates
7. ✅ Search across users, bookings, disputes
8. ✅ Export user data → verify GDPR compliance

---

## 📅 IMPLEMENTATION PRIORITY

### Phase 1 (P0 - Week 1):
- Enhanced user detail endpoint
- User bookings endpoint
- Disputes list & detail endpoints
- Create/update dispute endpoints

### Phase 2 (P1 - Week 2):
- Activity log endpoint
- Payment history endpoint
- Reviews endpoint
- Dispute messaging system

### Phase 3 (P2 - Week 3):
- Bulk operations
- Export functionality
- Advanced analytics
- Notification system

---

## 🔗 RELATED TICKETS

- `FRONTEND-EU-001` - Frontend implementation (this will be created after backend delivery)
- `DB-SCHEMA-003` - Database schema for disputes table
- `NOTIFICATION-002` - Notification service integration

---

## ✅ ACCEPTANCE CRITERIA

1. ✅ All 18 endpoints implemented and tested
2. ✅ Complete API documentation in Swagger/OpenAPI
3. ✅ Sample responses for all endpoints
4. ✅ Error handling for all edge cases
5. ✅ Proper authentication & authorization
6. ✅ Audit logging for all admin actions
7. ✅ Performance meets requirements
8. ✅ Unit tests >80% coverage
9. ✅ Integration tests for critical flows
10. ✅ Postman collection provided

---

## 📝 NOTES FOR BACKEND TEAM

1. **Dispute Resolution Workflow:**
   - When dispute is created, set `resolution_deadline` = created_at + 48 hours
   - Send email notifications to user, vendor, and assigned admin
   - Auto-escalate if not resolved within deadline

2. **Trust Score Calculation:**
   ```
   trust_score = (
     booking_completion_rate * 30 +
     payment_success_rate * 25 +
     (1 - dispute_rate) * 20 +
     avg_rating_given * 15 +
     account_age_factor * 10
   )
   ```

3. **Refund Integration:**
   - Dispute resolution with `refund_amount` should trigger payment gateway refund API
   - Update booking status to `refunded`
   - Create audit log entry

4. **Search Optimization:**
   - Index: email, phone, name for user search
   - Full-text search on dispute descriptions

---

## 🚀 EXPECTED RESPONSE

Please provide:
1. ✅ Confirmation of requirements understood
2. ✅ Estimated timeline for each phase
3. ✅ Any technical concerns or limitations
4. ✅ Database schema changes needed
5. ✅ API documentation link once ready
6. ✅ Test environment endpoint URLs
7. ✅ Sample Postman collection

---

**Ticket Status:** 📝 Open - Awaiting Backend Team Response  
**Frontend Blocked:** Yes - Cannot proceed with enhanced Users section until APIs are ready  
**Business Impact:** High - Critical for customer support and dispute resolution  

---

**Created By:** Frontend Development Team  
**Assigned To:** Backend API Team  
**CC:** Product Manager, Support Team Lead
