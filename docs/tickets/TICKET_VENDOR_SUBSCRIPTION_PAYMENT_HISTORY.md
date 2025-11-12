# Backend Ticket: Vendor Subscription Payment History API

## Priority: HIGH
## Category: Payment & Subscription Management
## Created: 2025-11-12

---

## Overview
Implement API endpoints to fetch vendor subscription payment history with date range filtering, pagination, and detailed payment information for admin dashboard.

---

## Required Endpoints

### 1. List Vendor Subscription Payments
**Endpoint:** `GET /api/v1/admin/subscriptions/payments`

**Description:** Retrieve paginated list of all subscription payments with filtering capabilities

**Query Parameters:**
```typescript
{
  // Pagination
  page?: number;          // Default: 1
  page_size?: number;     // Default: 20, Max: 100
  
  // Filters
  vendor_id?: number;     // Filter by specific vendor
  subscription_id?: number; // Filter by specific subscription
  status?: string;        // 'succeeded', 'failed', 'pending', 'refunded'
  
  // Date range filters
  start_date?: string;    // ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss)
  end_date?: string;      // ISO 8601 format
  
  // Additional filters
  plan_id?: number;       // Filter by plan
  amount_min?: number;    // Minimum amount in cents
  amount_max?: number;    // Maximum amount in cents
}
```

**Response Schema:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "pay_abc123xyz",
        "subscription_id": 42,
        "vendor_id": 7,
        "vendor_name": "John's Plumbing Services",
        "plan_id": 3,
        "plan_name": "Professional Monthly",
        "amount_cents": 4999,
        "currency": "usd",
        "status": "succeeded",
        "payment_method": "card",
        "payment_method_details": {
          "card_brand": "visa",
          "last4": "4242"
        },
        "description": "Subscription renewal - Professional Monthly",
        "invoice_id": "inv_xyz789",
        "invoice_url": "https://...",
        "created_at": "2025-11-01T10:30:00Z",
        "succeeded_at": "2025-11-01T10:30:05Z",
        "failed_at": null,
        "refunded_at": null,
        "metadata": {
          "billing_cycle": "2025-11",
          "renewal_count": 5
        }
      }
    ],
    "total": 150,
    "page": 1,
    "page_size": 20,
    "total_pages": 8
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid query parameters
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Insufficient permissions

**Required Permissions:** `payments.view`, `subscriptions.view`

---

### 2. Get Subscription Payment Details
**Endpoint:** `GET /api/v1/admin/subscriptions/payments/{payment_id}`

**Description:** Retrieve detailed information about a specific subscription payment

**Path Parameters:**
- `payment_id` (string, required) - The payment ID

**Response Schema:**
```json
{
  "success": true,
  "data": {
    "id": "pay_abc123xyz",
    "subscription_id": 42,
    "vendor_id": 7,
    "vendor_name": "John's Plumbing Services",
    "vendor_email": "john@plumbing.com",
    "plan_id": 3,
    "plan_name": "Professional Monthly",
    "plan_code": "pro_monthly",
    "amount_cents": 4999,
    "currency": "usd",
    "status": "succeeded",
    "payment_method": "card",
    "payment_method_details": {
      "card_brand": "visa",
      "card_country": "US",
      "last4": "4242",
      "exp_month": 12,
      "exp_year": 2026
    },
    "billing_details": {
      "name": "John Smith",
      "email": "john@plumbing.com",
      "address": {
        "line1": "123 Main St",
        "city": "New York",
        "state": "NY",
        "postal_code": "10001",
        "country": "US"
      }
    },
    "description": "Subscription renewal - Professional Monthly",
    "invoice_id": "inv_xyz789",
    "invoice_url": "https://...",
    "receipt_url": "https://...",
    "created_at": "2025-11-01T10:30:00Z",
    "succeeded_at": "2025-11-01T10:30:05Z",
    "failed_at": null,
    "refunded_at": null,
    "refund_reason": null,
    "failure_code": null,
    "failure_message": null,
    "metadata": {
      "billing_cycle": "2025-11",
      "renewal_count": 5,
      "subscription_period_start": "2025-11-01",
      "subscription_period_end": "2025-12-01"
    }
  }
}
```

**Error Responses:**
- `404 Not Found` - Payment not found
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Insufficient permissions

---

### 3. Get Subscription Payment Summary
**Endpoint:** `GET /api/v1/admin/subscriptions/payments/summary`

**Description:** Get aggregated payment statistics for dashboard

**Query Parameters:**
```typescript
{
  start_date?: string;  // ISO 8601 format
  end_date?: string;    // ISO 8601 format
  vendor_id?: number;   // Filter by vendor
}
```

**Response Schema:**
```json
{
  "success": true,
  "data": {
    "total_payments": 1250,
    "successful_payments": 1180,
    "failed_payments": 45,
    "pending_payments": 15,
    "refunded_payments": 10,
    "total_amount_cents": 5624500,
    "successful_amount_cents": 5499000,
    "refunded_amount_cents": 49950,
    "average_payment_cents": 4499,
    "currency": "usd",
    "date_range": {
      "start": "2025-01-01T00:00:00Z",
      "end": "2025-11-12T23:59:59Z"
    },
    "by_status": {
      "succeeded": 1180,
      "failed": 45,
      "pending": 15,
      "refunded": 10
    },
    "by_month": [
      {
        "month": "2025-01",
        "count": 98,
        "amount_cents": 441020
      },
      {
        "month": "2025-02",
        "count": 105,
        "amount_cents": 472455
      }
    ]
  }
}
```

---

### 4. Download Subscription Payment Invoice
**Endpoint:** `GET /api/v1/admin/subscriptions/payments/{payment_id}/invoice`

**Description:** Download or get URL for payment invoice

**Path Parameters:**
- `payment_id` (string, required) - The payment ID

**Query Parameters:**
```typescript
{
  format?: string;  // 'pdf' (default) or 'url'
}
```

**Response (format=url):**
```json
{
  "success": true,
  "data": {
    "invoice_url": "https://...",
    "expires_at": "2025-11-12T15:00:00Z"
  }
}
```

**Response (format=pdf):**
- Content-Type: application/pdf
- Binary PDF data

---

## Database Schema Requirements

### Table: `subscription_payments`
```sql
CREATE TABLE subscription_payments (
  id VARCHAR(255) PRIMARY KEY,
  subscription_id INTEGER NOT NULL REFERENCES subscriptions(id),
  vendor_id INTEGER NOT NULL REFERENCES vendors(id),
  plan_id INTEGER NOT NULL REFERENCES plans(id),
  amount_cents INTEGER NOT NULL,
  currency VARCHAR(3) NOT NULL DEFAULT 'usd',
  status VARCHAR(50) NOT NULL,
  payment_method VARCHAR(50),
  payment_method_details JSONB,
  billing_details JSONB,
  description TEXT,
  invoice_id VARCHAR(255),
  invoice_url TEXT,
  receipt_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  succeeded_at TIMESTAMP WITH TIME ZONE,
  failed_at TIMESTAMP WITH TIME ZONE,
  refunded_at TIMESTAMP WITH TIME ZONE,
  refund_reason TEXT,
  failure_code VARCHAR(100),
  failure_message TEXT,
  metadata JSONB,
  
  INDEX idx_vendor_id (vendor_id),
  INDEX idx_subscription_id (subscription_id),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at),
  INDEX idx_vendor_created (vendor_id, created_at)
);
```

---

## Implementation Notes

1. **Date Range Filtering:**
   - Support both date-only (YYYY-MM-DD) and datetime (ISO 8601) formats
   - Default to UTC timezone if not specified
   - `start_date` should be inclusive (00:00:00)
   - `end_date` should be inclusive (23:59:59)

2. **Pagination:**
   - Use cursor-based or offset-based pagination
   - Include `total`, `page`, `page_size`, and `total_pages` in response
   - Enforce maximum page_size of 100

3. **Performance:**
   - Add database indexes on `vendor_id`, `created_at`, `status`
   - Consider caching for summary statistics
   - Optimize queries for large datasets (millions of payments)

4. **Security:**
   - Verify admin authentication and permissions
   - Sanitize all query parameters
   - Rate limit API calls (e.g., 100 requests per minute)

5. **Payment Integration:**
   - If using Stripe, map Stripe PaymentIntent/Charge to this schema
   - Store Stripe IDs in metadata for reconciliation
   - Sync payment status updates via webhooks

---

## Testing Requirements

1. **Unit Tests:**
   - Date range filtering (various formats)
   - Pagination edge cases
   - Invalid parameter handling
   - Permission validation

2. **Integration Tests:**
   - Full payment creation and retrieval flow
   - Multi-vendor payment isolation
   - Large dataset performance (>10k payments)

3. **Test Data:**
   - Generate sample payments across multiple months
   - Various payment statuses and amounts
   - Different vendors and plans

---

## API Examples

### Example 1: Get payments for November 2025
```bash
GET /api/v1/admin/subscriptions/payments?start_date=2025-11-01&end_date=2025-11-30&page=1&page_size=20
Authorization: Bearer <admin_token>
```

### Example 2: Get payments for specific vendor
```bash
GET /api/v1/admin/subscriptions/payments?vendor_id=7&page=1&page_size=50
Authorization: Bearer <admin_token>
```

### Example 3: Get failed payments in date range
```bash
GET /api/v1/admin/subscriptions/payments?status=failed&start_date=2025-10-01&end_date=2025-10-31
Authorization: Bearer <admin_token>
```

### Example 4: Get payment summary
```bash
GET /api/v1/admin/subscriptions/payments/summary?start_date=2025-01-01&end_date=2025-11-12
Authorization: Bearer <admin_token>
```

---

## Timeline Estimate
- **Backend Development:** 3-4 days
- **Testing:** 1-2 days
- **Documentation:** 0.5 day
- **Total:** ~5-7 days

---

## Dependencies
- Subscription management system
- Payment gateway integration (Stripe/other)
- Admin authentication system
- Permission system

---

## Related Documentation
- Backend API Documentation: `/docs/ADMIN_API_QUICK_REFERENCE.md`
- Subscription Management: `/docs/SUBSCRIPTION_MANAGEMENT.md`
- Payment Processing: `/docs/PAYMENT_INTEGRATION.md`
