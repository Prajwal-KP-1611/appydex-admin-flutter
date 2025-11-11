# Vendor Management Backend Requirements

## Overview
This document specifies the backend API endpoints required for the new two-view vendor management system:
1. **Vendor Onboarding** - For reviewing and approving new vendor applications
2. **Vendor Management** - For managing active vendors and their services/bookings

---

## 1. Vendor Onboarding APIs

### 1.1 Get Pending Vendors (Onboarding Queue)
**Endpoint:** `GET /api/v1/admin/vendors/onboarding`

**Description:** Retrieve vendors in onboarding stages (pending, onboarding, rejected)

**Query Parameters:**
- `page` (int, default: 1) - Page number
- `page_size` (int, default: 20) - Items per page
- `status` (string, optional) - Filter by status: "pending", "onboarding", "rejected"
- `search` (string, optional) - Search by company name, email, phone
- `sort_by` (string, default: "created_at") - Sort field
- `sort_order` (string, default: "desc") - "asc" or "desc"

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "user_id": 101,
        "company_name": "Tech Services Inc",
        "slug": "tech-services-inc",
        "status": "pending",
        "contact_email": "contact@techservices.com",
        "contact_phone": "+919876543210",
        "business_type": "LLC",
        "created_at": "2025-11-01T10:00:00Z",
        "updated_at": "2025-11-01T10:00:00Z",
        "submitted_at": "2025-11-01T10:00:00Z",
        "metadata": {
          "registration_number": "12345",
          "address": "123 Main St",
          "city": "Mumbai",
          "state": "Maharashtra",
          "pincode": "400001"
        },
        "documents": [
          {
            "id": 1,
            "type": "gst_certificate",
            "url": "https://...",
            "status": "pending",
            "uploaded_at": "2025-11-01T10:00:00Z"
          }
        ],
        "owner": {
          "id": 101,
          "email": "owner@techservices.com",
          "phone": "+919876543210",
          "name": "John Doe"
        }
      }
    ],
    "total": 45,
    "page": 1,
    "page_size": 20,
    "total_pages": 3
  }
}
```

---

### 1.2 Get Vendor Application Details
**Endpoint:** `GET /api/v1/admin/vendors/{vendor_id}/application`

**Description:** Get complete vendor application with all documents and metadata

**Response:**
```json
{
  "success": true,
  "data": {
    "vendor": {
      "id": 1,
      "user_id": 101,
      "company_name": "Tech Services Inc",
      "slug": "tech-services-inc",
      "status": "pending",
      "business_type": "LLC",
      "contact_email": "contact@techservices.com",
      "contact_phone": "+919876543210",
      "created_at": "2025-11-01T10:00:00Z",
      "submitted_at": "2025-11-01T10:00:00Z",
      "metadata": {
        "registration_number": "12345",
        "gst_number": "27AABCU9603R1ZX",
        "pan_number": "ABCDE1234F",
        "address": "123 Main St",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001",
        "bank_account_number": "1234567890",
        "bank_ifsc": "SBIN0001234",
        "bank_account_name": "Tech Services Inc"
      }
    },
    "documents": [
      {
        "id": 1,
        "type": "gst_certificate",
        "url": "https://storage.../gst.pdf",
        "status": "pending",
        "uploaded_at": "2025-11-01T10:00:00Z"
      },
      {
        "id": 2,
        "type": "pan_card",
        "url": "https://storage.../pan.pdf",
        "status": "pending",
        "uploaded_at": "2025-11-01T10:00:00Z"
      },
      {
        "id": 3,
        "type": "bank_proof",
        "url": "https://storage.../bank.pdf",
        "status": "pending",
        "uploaded_at": "2025-11-01T10:00:00Z"
      }
    ],
    "owner": {
      "id": 101,
      "email": "owner@techservices.com",
      "phone": "+919876543210",
      "name": "John Doe",
      "email_verified": true,
      "phone_verified": true,
      "created_at": "2025-10-15T08:00:00Z"
    },
    "review_history": [
      {
        "id": 1,
        "action": "document_requested",
        "admin_id": 1,
        "admin_name": "Admin User",
        "notes": "Please upload GST certificate",
        "created_at": "2025-11-02T09:00:00Z"
      }
    ]
  }
}
```

---

### 1.3 Approve Vendor
**Endpoint:** `POST /api/v1/admin/vendors/{vendor_id}/approve`

**Description:** Approve vendor application and transition to "verified" status

**Request Body:**
```json
{
  "notes": "All documents verified. Approved for onboarding.",
  "initial_commission_rate": 15.0,
  "verification_details": {
    "gst_verified": true,
    "pan_verified": true,
    "bank_verified": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "vendor_id": 1,
    "status": "verified",
    "approved_at": "2025-11-10T10:00:00Z",
    "approved_by": 1,
    "message": "Vendor approved successfully"
  }
}
```

---

### 1.4 Reject Vendor
**Endpoint:** `POST /api/v1/admin/vendors/{vendor_id}/reject`

**Description:** Reject vendor application

**Request Body:**
```json
{
  "reason": "Invalid GST certificate",
  "details": "The GST certificate provided does not match the company name",
  "allow_reapply": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "vendor_id": 1,
    "status": "rejected",
    "rejected_at": "2025-11-10T10:00:00Z",
    "rejected_by": 1,
    "message": "Vendor application rejected"
  }
}
```

---

### 1.5 Request Additional Documents
**Endpoint:** `POST /api/v1/admin/vendors/{vendor_id}/request-documents`

**Description:** Request additional or corrected documents from vendor

**Request Body:**
```json
{
  "document_types": ["gst_certificate", "bank_proof"],
  "message": "Please re-upload a clear copy of your GST certificate and bank proof",
  "deadline": "2025-11-20T23:59:59Z"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "request_id": 123,
    "vendor_id": 1,
    "status": "pending_documents",
    "message": "Document request sent to vendor"
  }
}
```

---

### 1.6 Verify Individual Document
**Endpoint:** `POST /api/v1/admin/vendors/{vendor_id}/documents/{document_id}/verify`

**Description:** Mark a specific document as verified or rejected

**Request Body:**
```json
{
  "status": "verified",
  "notes": "GST certificate verified successfully"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "document_id": 1,
    "status": "verified",
    "verified_by": 1,
    "verified_at": "2025-11-10T10:00:00Z"
  }
}
```

---

## 2. Vendor Management APIs

### 2.1 Get Active Vendors
**Endpoint:** `GET /api/v1/admin/vendors/active`

**Description:** Get verified and suspended vendors for management

**Query Parameters:**
- `page` (int, default: 1)
- `page_size` (int, default: 20)
- `status` (string, optional) - "verified", "suspended"
- `search` (string, optional) - Search by company name, email, phone
- `has_active_services` (bool, optional) - Filter vendors with active services
- `has_pending_bookings` (bool, optional) - Filter vendors with pending bookings
- `sort_by` (string, default: "company_name")
- `sort_order` (string, default: "asc")

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "company_name": "Tech Services Inc",
        "slug": "tech-services-inc",
        "status": "verified",
        "contact_email": "contact@techservices.com",
        "contact_phone": "+919876543210",
        "verified_at": "2025-11-05T10:00:00Z",
        "stats": {
          "total_services": 15,
          "active_services": 12,
          "total_bookings": 450,
          "pending_bookings": 5,
          "completed_bookings": 430,
          "cancelled_bookings": 15,
          "total_revenue": 1250000.00,
          "commission_earned": 187500.00,
          "average_rating": 4.5,
          "total_reviews": 320
        },
        "last_booking_at": "2025-11-09T15:30:00Z",
        "last_active_at": "2025-11-10T08:00:00Z"
      }
    ],
    "total": 156,
    "page": 1,
    "page_size": 20,
    "total_pages": 8
  }
}
```

---

### 2.2 Get Vendor Services
**Endpoint:** `GET /api/v1/admin/vendors/{vendor_id}/services`

**Description:** Get all services for a specific vendor

**Query Parameters:**
- `page` (int, default: 1)
- `page_size` (int, default: 50)
- `status` (string, optional) - "active", "inactive", "draft"
- `category_id` (int, optional)

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 100,
        "vendor_id": 1,
        "name": "AC Repair Service",
        "slug": "ac-repair-service",
        "category": {
          "id": 5,
          "name": "Home Appliances",
          "slug": "home-appliances"
        },
        "status": "active",
        "price": 599.00,
        "duration_minutes": 60,
        "is_featured": true,
        "bookings_count": 145,
        "average_rating": 4.7,
        "created_at": "2025-09-01T10:00:00Z",
        "updated_at": "2025-11-01T10:00:00Z"
      }
    ],
    "total": 15,
    "page": 1,
    "page_size": 50
  }
}
```

---

### 2.3 Update Vendor Service Status
**Endpoint:** `PATCH /api/v1/admin/vendors/{vendor_id}/services/{service_id}`

**Description:** Admin can activate/deactivate vendor services

**Request Body:**
```json
{
  "status": "inactive",
  "reason": "Service quality issues reported",
  "admin_notes": "Temporarily disabled pending quality review"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "service_id": 100,
    "status": "inactive",
    "updated_by": 1,
    "updated_at": "2025-11-10T10:00:00Z"
  }
}
```

---

### 2.4 Get Vendor Bookings
**Endpoint:** `GET /api/v1/admin/vendors/{vendor_id}/bookings`

**Description:** Get all bookings for a specific vendor

**Query Parameters:**
- `page` (int, default: 1)
- `page_size` (int, default: 50)
- `status` (string, optional) - "pending", "confirmed", "completed", "cancelled"
- `from_date` (string, optional) - ISO date
- `to_date` (string, optional) - ISO date

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1001,
        "booking_number": "BK-2025-001001",
        "user": {
          "id": 501,
          "name": "Customer Name",
          "email": "customer@example.com",
          "phone": "+919876543210"
        },
        "service": {
          "id": 100,
          "name": "AC Repair Service",
          "price": 599.00
        },
        "status": "confirmed",
        "scheduled_at": "2025-11-15T14:00:00Z",
        "total_amount": 599.00,
        "payment_status": "paid",
        "created_at": "2025-11-08T10:00:00Z"
      }
    ],
    "total": 450,
    "page": 1,
    "page_size": 50
  }
}
```

---

### 2.5 Cancel Vendor Booking (Admin Override)
**Endpoint:** `POST /api/v1/admin/vendors/{vendor_id}/bookings/{booking_id}/cancel`

**Description:** Admin can cancel bookings on behalf of vendor

**Request Body:**
```json
{
  "reason": "Vendor unavailable due to emergency",
  "refund_amount": 599.00,
  "notify_customer": true,
  "admin_notes": "Full refund issued"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "booking_id": 1001,
    "status": "cancelled",
    "refund_status": "processed",
    "refund_amount": 599.00,
    "cancelled_by": 1,
    "cancelled_at": "2025-11-10T10:00:00Z"
  }
}
```

---

### 2.6 Get Vendor Dashboard Stats
**Endpoint:** `GET /api/v1/admin/vendors/{vendor_id}/stats`

**Description:** Get comprehensive statistics for vendor performance

**Query Parameters:**
- `period` (string, default: "30d") - "7d", "30d", "90d", "1y", "all"

**Response:**
```json
{
  "success": true,
  "data": {
    "vendor_id": 1,
    "period": "30d",
    "services": {
      "total": 15,
      "active": 12,
      "inactive": 3
    },
    "bookings": {
      "total": 45,
      "pending": 5,
      "confirmed": 8,
      "completed": 30,
      "cancelled": 2
    },
    "revenue": {
      "total": 125000.00,
      "commission": 18750.00,
      "vendor_earnings": 106250.00
    },
    "ratings": {
      "average": 4.5,
      "total_reviews": 28,
      "distribution": {
        "5": 18,
        "4": 8,
        "3": 2,
        "2": 0,
        "1": 0
      }
    },
    "customers": {
      "total": 38,
      "returning": 7
    }
  }
}
```

---

### 2.7 Update Vendor Commission Rate
**Endpoint:** `PATCH /api/v1/admin/vendors/{vendor_id}/commission`

**Description:** Admin can adjust vendor commission rate

**Request Body:**
```json
{
  "commission_rate": 12.0,
  "effective_from": "2025-12-01T00:00:00Z",
  "reason": "Performance-based reduction",
  "admin_notes": "Reduced due to high volume"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "vendor_id": 1,
    "previous_rate": 15.0,
    "new_rate": 12.0,
    "effective_from": "2025-12-01T00:00:00Z",
    "updated_by": 1,
    "updated_at": "2025-11-10T10:00:00Z"
  }
}
```

---

### 2.8 Get Vendor Payment History
**Endpoint:** `GET /api/v1/admin/vendors/{vendor_id}/payments`

**Description:** Get payment/settlement history for vendor

**Query Parameters:**
- `page` (int, default: 1)
- `page_size` (int, default: 20)
- `status` (string, optional) - "pending", "processing", "completed", "failed"
- `from_date` (string, optional)
- `to_date` (string, optional)

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 5001,
        "vendor_id": 1,
        "period_start": "2025-10-01T00:00:00Z",
        "period_end": "2025-10-31T23:59:59Z",
        "total_bookings": 45,
        "gross_amount": 125000.00,
        "commission_amount": 18750.00,
        "net_amount": 106250.00,
        "status": "completed",
        "paid_at": "2025-11-05T10:00:00Z",
        "payment_method": "bank_transfer",
        "transaction_id": "TXN-12345"
      }
    ],
    "total": 12,
    "page": 1,
    "page_size": 20
  }
}
```

---

### 2.9 Bulk Actions on Vendors
**Endpoint:** `POST /api/v1/admin/vendors/bulk-action`

**Description:** Perform bulk actions on multiple vendors

**Request Body:**
```json
{
  "action": "suspend",
  "vendor_ids": [1, 2, 3, 4],
  "reason": "Quality audit in progress",
  "duration_days": 7,
  "admin_notes": "Temporary suspension for audit"
}
```

**Supported Actions:**
- `suspend` - Suspend vendors
- `reactivate` - Reactivate suspended vendors
- `update_commission` - Update commission rate
- `send_notification` - Send bulk notification

**Response:**
```json
{
  "success": true,
  "data": {
    "action": "suspend",
    "total_vendors": 4,
    "successful": 4,
    "failed": 0,
    "results": [
      {
        "vendor_id": 1,
        "status": "success"
      },
      {
        "vendor_id": 2,
        "status": "success"
      }
    ]
  }
}
```

---

## 3. Additional Requirements

### 3.1 Notifications
- Email/SMS notification to vendor on approval
- Email/SMS notification to vendor on rejection
- Email/SMS notification on suspension
- Email/SMS notification on reactivation
- Notification on document request

### 3.2 Audit Logging
All admin actions should be logged:
- Who performed the action
- What action was performed
- When it was performed
- Affected entity (vendor_id)
- Additional context (reason, notes)

### 3.3 Permissions
Admin permissions required:
- `vendors.onboarding.view` - View onboarding queue
- `vendors.onboarding.approve` - Approve vendors
- `vendors.onboarding.reject` - Reject vendors
- `vendors.manage.view` - View active vendors
- `vendors.manage.edit` - Edit vendor details
- `vendors.manage.suspend` - Suspend vendors
- `vendors.services.view` - View vendor services
- `vendors.services.edit` - Edit vendor services
- `vendors.bookings.view` - View vendor bookings
- `vendors.bookings.cancel` - Cancel vendor bookings
- `vendors.payments.view` - View vendor payments

---

## 4. Response Error Codes

Standard error responses:
- `404` - Vendor not found
- `403` - Insufficient permissions
- `422` - Validation error (invalid status transition, missing required fields)
- `409` - Conflict (e.g., vendor already approved)
- `500` - Server error

---

## Priority

**High Priority (Required for MVP):**
- 1.1, 1.3, 1.4 - Basic onboarding flow
- 2.1 - Active vendors listing
- 2.2, 2.4 - View services and bookings

**Medium Priority:**
- 1.2, 1.5, 1.6 - Detailed application review
- 2.3, 2.5, 2.6 - Service/booking management
- 2.7, 2.8 - Commission and payments

**Low Priority (Nice to have):**
- 2.9 - Bulk actions
