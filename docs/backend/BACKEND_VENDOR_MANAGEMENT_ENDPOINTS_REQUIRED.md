# Backend Ticket: Comprehensive Vendor Management API Endpoints

**Date:** November 9, 2025  
**Priority:** HIGH  
**Component:** Backend API - Vendor Management  
**Requester:** Frontend Admin Panel Team

---

## Overview

The admin panel requires comprehensive vendor management capabilities to handle:
1. **Vendor Applications** - Both fully registered and in-progress registrations
2. **Application Approval/Rejection** - Review and decide on vendor applications
3. **Vendor Operations** - Manage bookings, leads, services, revenue
4. **Vendor Analytics** - Track performance, revenue, activity metrics
5. **Vendor Documents** - KYC verification, business licenses
6. **Vendor Status Management** - Suspend, activate, ban vendors

---

## Current State

### ✅ **Already Implemented:**
- `GET /api/v1/admin/vendors` - List vendors with pagination
- `GET /api/v1/admin/vendors/{id}` - Get vendor details
- `POST /api/v1/admin/vendors/{id}/verify?status=verified|rejected` - Approve/reject vendor

---

## Required Endpoints

### 1. **Vendor Applications & Registration**

#### 1.1 Get Vendor Application Details
```
GET /api/v1/admin/vendors/{vendor_id}/application
```

**Purpose:** View detailed application data including partial/incomplete registrations

**Response:**
```json
{
  "vendor_id": 123,
  "user_id": 456,
  "company_name": "ABC Services Ltd",
  "registration_status": "pending_documents|pending_verification|completed",
  "registration_progress": 75,
  "registration_step": "documents_upload",
  "applied_at": "2025-11-01T10:00:00Z",
  "application_data": {
    "business_type": "private_limited",
    "gst_number": "29ABCDE1234F1Z5",
    "pan_number": "ABCDE1234F",
    "registered_address": {...},
    "contact_person": {...},
    "bank_details": {...}
  },
  "incomplete_fields": ["bank_details.account_number", "documents.business_license"],
  "submitted_documents": [
    {
      "type": "pan_card",
      "status": "verified",
      "url": "..."
    }
  ],
  "missing_documents": ["business_license", "cancelled_cheque"]
}
```

#### 1.2 Update Application Status
```
PATCH /api/v1/admin/vendors/{vendor_id}/application
```

**Body:**
```json
{
  "registration_status": "pending_verification",
  "admin_notes": "Requested additional documents",
  "required_actions": ["upload_business_license", "verify_bank_details"]
}
```

---

### 2. **Vendor Services Management**

#### 2.1 List Vendor Services
```
GET /api/v1/admin/vendors/{vendor_id}/services
```

**Query Parameters:**
- `page`, `limit` - Pagination
- `status` - active, inactive, pending_approval
- `category` - Filter by service category

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "vendor_id": 123,
      "name": "Professional Cleaning Service",
      "category": "cleaning",
      "subcategory": "residential",
      "status": "active",
      "pricing": {
        "base_price": 50000,
        "currency": "INR",
        "pricing_type": "per_hour"
      },
      "is_featured": false,
      "views_count": 1250,
      "bookings_count": 45,
      "rating": 4.7,
      "created_at": "2025-10-15T00:00:00Z"
    }
  ],
  "meta": {
    "total": 15,
    "page": 1,
    "page_size": 20
  }
}
```

#### 2.2 Approve/Reject Service
```
POST /api/v1/admin/vendors/{vendor_id}/services/{service_id}/review
```

**Body:**
```json
{
  "action": "approve|reject|request_changes",
  "notes": "Service description needs improvement",
  "required_changes": ["update_description", "add_pricing_details"]
}
```

#### 2.3 Feature/Unfeature Service
```
PATCH /api/v1/admin/vendors/{vendor_id}/services/{service_id}/feature
```

**Body:**
```json
{
  "is_featured": true,
  "featured_until": "2025-12-31T23:59:59Z"
}
```

---

### 3. **Vendor Bookings Management**

#### 3.1 List Vendor Bookings
```
GET /api/v1/admin/vendors/{vendor_id}/bookings
```

**Query Parameters:**
- `page`, `limit` - Pagination
- `status` - pending, confirmed, completed, cancelled
- `from_date`, `to_date` - Date range
- `sort` - created_at, booking_date, amount

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "booking_reference": "BK-2025-001234",
      "customer_id": 789,
      "customer_name": "John Doe",
      "service_id": "uuid",
      "service_name": "Home Cleaning",
      "status": "completed",
      "booking_date": "2025-11-05T14:00:00Z",
      "amount": 250000,
      "commission": 25000,
      "vendor_payout": 225000,
      "payment_status": "paid",
      "created_at": "2025-11-01T10:00:00Z"
    }
  ],
  "meta": {
    "total": 150,
    "page": 1,
    "page_size": 20
  },
  "summary": {
    "total_bookings": 150,
    "pending": 5,
    "confirmed": 10,
    "completed": 130,
    "cancelled": 5,
    "total_revenue": 37500000,
    "total_commission": 3750000
  }
}
```

---

### 4. **Vendor Leads Management**

#### 4.1 List Vendor Leads
```
GET /api/v1/admin/vendors/{vendor_id}/leads
```

**Query Parameters:**
- `page`, `limit`
- `status` - new, contacted, converted, lost
- `from_date`, `to_date`

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "customer_name": "Jane Smith",
      "customer_phone": "+919876543210",
      "customer_email": "jane@example.com",
      "service_requested": "Wedding Photography",
      "status": "new",
      "budget": 500000,
      "event_date": "2025-12-15",
      "message": "Looking for professional photographer...",
      "source": "website|app|referral",
      "created_at": "2025-11-08T15:30:00Z",
      "last_contacted_at": null,
      "converted_to_booking_id": null
    }
  ],
  "meta": {...},
  "summary": {
    "total_leads": 50,
    "new": 15,
    "contacted": 20,
    "converted": 10,
    "lost": 5,
    "conversion_rate": 20.0
  }
}
```

---

### 5. **Vendor Revenue & Payouts**

#### 5.1 Get Vendor Revenue Summary
```
GET /api/v1/admin/vendors/{vendor_id}/revenue
```

**Query Parameters:**
- `from_date`, `to_date`
- `group_by` - day, week, month

**Response:**
```json
{
  "summary": {
    "total_bookings_value": 5000000,
    "platform_commission": 500000,
    "vendor_earnings": 4500000,
    "tax_deducted": 450000,
    "net_payable": 4050000,
    "paid_amount": 3000000,
    "pending_payout": 1050000
  },
  "time_series": [
    {
      "date": "2025-11-01",
      "bookings": 5,
      "revenue": 250000,
      "commission": 25000
    }
  ],
  "commission_breakdown": {
    "base_commission_rate": 10.0,
    "total_commission": 500000,
    "promotional_discounts": 50000,
    "net_commission": 450000
  }
}
```

#### 5.2 List Vendor Payouts
```
GET /api/v1/admin/vendors/{vendor_id}/payouts
```

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "payout_reference": "PO-2025-001234",
      "period_start": "2025-10-01",
      "period_end": "2025-10-31",
      "gross_amount": 1000000,
      "deductions": 100000,
      "net_amount": 900000,
      "status": "processed|pending|failed",
      "payment_method": "bank_transfer",
      "processed_at": "2025-11-05T00:00:00Z",
      "utr_number": "HDFC1234567890"
    }
  ],
  "meta": {...}
}
```

#### 5.3 Initiate Payout
```
POST /api/v1/admin/vendors/{vendor_id}/payouts
```

**Body:**
```json
{
  "period_start": "2025-11-01",
  "period_end": "2025-11-30",
  "amount": 1500000,
  "payment_method": "bank_transfer",
  "notes": "Monthly payout for November"
}
```

---

### 6. **Vendor Analytics**

#### 6.1 Get Vendor Performance Metrics
```
GET /api/v1/admin/vendors/{vendor_id}/analytics
```

**Query Parameters:**
- `from_date`, `to_date`

**Response:**
```json
{
  "period": {
    "start": "2025-10-01",
    "end": "2025-11-09"
  },
  "performance": {
    "total_bookings": 150,
    "completed_bookings": 140,
    "cancelled_bookings": 10,
    "completion_rate": 93.3,
    "average_rating": 4.7,
    "total_reviews": 85,
    "response_time_avg_minutes": 45,
    "acceptance_rate": 95.0
  },
  "revenue": {
    "total_revenue": 5000000,
    "growth_pct": 25.5,
    "average_booking_value": 33333
  },
  "customer_metrics": {
    "unique_customers": 120,
    "repeat_customers": 30,
    "repeat_rate": 25.0
  },
  "service_metrics": {
    "active_services": 12,
    "total_views": 15000,
    "conversion_rate": 3.5
  }
}
```

---

### 7. **Vendor Status Management**

#### 7.1 Suspend Vendor
```
PATCH /api/v1/admin/vendors/{vendor_id}/suspend
```

**Body:**
```json
{
  "reason": "Policy violation - multiple customer complaints",
  "duration_days": 30,
  "notify_vendor": true,
  "block_new_bookings": true
}
```

**Response:**
```json
{
  "vendor_id": 123,
  "status": "suspended",
  "suspended_until": "2025-12-09T00:00:00Z",
  "reason": "...",
  "suspended_by": 1,
  "suspended_at": "2025-11-09T08:00:00Z"
}
```

#### 7.2 Reactivate Vendor
```
PATCH /api/v1/admin/vendors/{vendor_id}/reactivate
```

**Body:**
```json
{
  "notes": "Issue resolved, vendor can resume operations"
}
```

#### 7.3 Ban Vendor (Permanent)
```
POST /api/v1/admin/vendors/{vendor_id}/ban
```

**Body:**
```json
{
  "reason": "Fraudulent activity detected",
  "permanent": true,
  "blacklist_user": true
}
```

---

### 8. **Vendor Document Verification**

#### 8.1 List Vendor Documents
```
GET /api/v1/admin/vendors/{vendor_id}/documents
```

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "type": "business_license|pan_card|gst_certificate|bank_proof",
      "status": "pending|verified|rejected",
      "uploaded_at": "2025-11-01T00:00:00Z",
      "verified_at": null,
      "verified_by": null,
      "file_url": "https://...",
      "file_name": "business_license.pdf",
      "file_size": 1024000,
      "notes": ""
    }
  ]
}
```

#### 8.2 Verify/Reject Document
```
POST /api/v1/admin/vendors/{vendor_id}/documents/{document_id}/verify
```

**Body:**
```json
{
  "status": "verified|rejected",
  "notes": "Document is clear and valid"
}
```

---

### 9. **Vendor Activity & Audit Log**

#### 9.1 Get Vendor Activity Log
```
GET /api/v1/admin/vendors/{vendor_id}/activity
```

**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "action": "status_change|service_added|booking_completed|payout_processed",
      "description": "Vendor status changed from pending to verified",
      "performed_by": "admin_user_name",
      "performed_by_id": 1,
      "timestamp": "2025-11-01T10:00:00Z",
      "metadata": {
        "old_status": "pending",
        "new_status": "verified"
      }
    }
  ],
  "meta": {...}
}
```

---

### 10. **Vendor Notifications & Communication**

#### 10.1 Send Notification to Vendor
```
POST /api/v1/admin/vendors/{vendor_id}/notify
```

**Body:**
```json
{
  "type": "email|sms|push|in_app",
  "subject": "Important Update Regarding Your Account",
  "message": "...",
  "priority": "high|normal|low",
  "action_required": true,
  "action_url": "https://vendor.appydex.com/action/xyz"
}
```

---

### 11. **Bulk Operations**

#### 11.1 Bulk Approve Vendors
```
POST /api/v1/admin/vendors/bulk/approve
```

**Body:**
```json
{
  "vendor_ids": [123, 456, 789],
  "notes": "Approved after verification"
}
```

#### 11.2 Bulk Export Vendor Data
```
POST /api/v1/admin/vendors/export
```

**Body:**
```json
{
  "filters": {
    "status": "verified",
    "created_after": "2025-01-01"
  },
  "format": "csv|xlsx|json",
  "fields": ["id", "company_name", "status", "total_revenue", "bookings_count"]
}
```

**Response:**
```json
{
  "export_id": "uuid",
  "status": "processing",
  "download_url": null,
  "estimated_completion": "2025-11-09T08:05:00Z"
}
```

---

## Priority Breakdown

### **P0 - Critical (Immediate Implementation Required):**
1. Vendor Applications Details (1.1)
2. Vendor Services List (2.1)
3. Vendor Bookings List (3.1)
4. Vendor Revenue Summary (5.1)
5. Suspend/Reactivate Vendor (7.1, 7.2)

### **P1 - High (Within 1 Week):**
6. Vendor Leads Management (4.1)
7. Vendor Payouts List (5.2)
8. Vendor Analytics (6.1)
9. Document Verification (8.2)

### **P2 - Medium (Within 2 Weeks):**
10. Service Approval (2.2, 2.3)
11. Initiate Payout (5.3)
12. Activity Log (9.1)
13. Vendor Notifications (10.1)

### **P3 - Low (Future Enhancement):**
14. Bulk Operations (11.1, 11.2)
15. Update Application Status (1.2)

---

## Implementation Notes

### Authentication
All endpoints require:
```
Authorization: Bearer <admin_jwt_token>
```

### Response Format
All responses wrapped in standard envelope:
```json
{
  "success": true,
  "data": {...}
}
```

Or error format:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

### Pagination
Standard format (already used in `/admin/vendors`):
```json
{
  "items": [...],
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### Permissions
Endpoints should check for appropriate admin permissions:
- `vendors.view` - Read operations
- `vendors.edit` - Update operations
- `vendors.verify` - Approval/rejection
- `vendors.delete` - Ban/permanent actions
- `vendors.payouts` - Financial operations

---

## Testing Requirements

Each endpoint should include:
1. Unit tests for business logic
2. Integration tests with database
3. API endpoint tests (status codes, response format)
4. Permission/authorization tests
5. Rate limiting tests

---

## Documentation Requirements

For each endpoint, provide:
1. OpenAPI/Swagger specification
2. Example requests/responses
3. Error codes and handling
4. Rate limits
5. Sample cURL commands

---

**End of Ticket**
