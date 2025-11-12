# 🎯 Backend Ticket: Complete Analytics Endpoints Implementation

**Priority:** HIGH  
**Ticket ID:** BACKEND-ANALYTICS-001  
**Date Created:** November 12, 2025  
**Status:** ⏳ PENDING BACKEND IMPLEMENTATION  
**Estimated Effort:** 3-4 days

---

## 📋 Executive Summary

The admin frontend has partial analytics implementation (50% coverage - 3/6 endpoints). This ticket covers the **3 missing analytics endpoints** required to achieve 100% feature completion:

1. ❌ `GET /api/v1/admin/analytics/bookings` - Booking analytics with time series
2. ❌ `GET /api/v1/admin/analytics/revenue` - Revenue analytics with time series
3. ❌ `GET /api/v1/admin/jobs/{job_id}` - Export job status polling (needed for analytics export)

### ✅ Already Implemented (No Action Needed)
- ✅ `GET /api/v1/admin/analytics/top-searches` - Working
- ✅ `GET /api/v1/admin/analytics/ctr` - Working
- ✅ `POST /api/v1/admin/analytics/export` - Working (but needs job polling endpoint)

---

## 🎯 Missing Endpoints

### 1. GET /api/v1/admin/analytics/bookings

**Purpose:** Provide booking analytics with time series data for admin dashboard

**Path:** `/api/v1/admin/analytics/bookings`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `analytics:view` or `super_admin`

#### Request

**Query Parameters:**
```typescript
{
  from: string;          // ISO 8601 date (required) - "2025-10-01T00:00:00Z"
  to: string;            // ISO 8601 date (required) - "2025-10-31T23:59:59Z"
  granularity?: string;  // "day" | "week" | "month" (default: "day")
  vendor_id?: string;    // Filter by vendor UUID (optional)
  status?: string;       // "pending" | "confirmed" | "completed" | "cancelled" (optional)
  city?: string;         // Filter by city (optional)
  category?: string;     // Filter by service category (optional)
}
```

**Example Request:**
```bash
GET /api/v1/admin/analytics/bookings?from=2025-10-01T00:00:00Z&to=2025-10-31T23:59:59Z&granularity=day
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "time_series": [
      {
        "date": "2025-10-01",
        "total_bookings": 45,
        "pending": 5,
        "confirmed": 15,
        "completed": 20,
        "cancelled": 5,
        "total_value_cents": 125000,
        "avg_value_cents": 2777
      },
      {
        "date": "2025-10-02",
        "total_bookings": 52,
        "pending": 8,
        "confirmed": 18,
        "completed": 22,
        "cancelled": 4,
        "total_value_cents": 145000,
        "avg_value_cents": 2788
      }
    ],
    "summary": {
      "total_bookings": 1450,
      "pending": 125,
      "confirmed": 450,
      "completed": 750,
      "cancelled": 125,
      "total_value_cents": 4250000,
      "avg_value_cents": 2931,
      "conversion_rate": 0.82,
      "cancellation_rate": 0.09
    },
    "top_services": [
      {
        "service_id": "uuid",
        "service_name": "Plumbing Services",
        "bookings_count": 245,
        "total_value_cents": 850000
      }
    ],
    "top_vendors": [
      {
        "vendor_id": "uuid",
        "vendor_name": "ABC Services",
        "bookings_count": 189,
        "total_value_cents": 650000
      }
    ]
  },
  "meta": {
    "from": "2025-10-01T00:00:00Z",
    "to": "2025-10-31T23:59:59Z",
    "granularity": "day",
    "filters_applied": {
      "city": null,
      "category": null,
      "vendor_id": null,
      "status": null
    }
  }
}
```

**Error Responses:**

**400 Bad Request - Invalid Date Range:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_DATE_RANGE",
    "message": "Start date must be before end date",
    "details": {
      "from": "2025-11-01",
      "to": "2025-10-01"
    }
  }
}
```

**403 Forbidden - Missing Permission:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to view analytics",
    "required_permission": "analytics:view"
  }
}
```

#### Implementation Notes

1. **Data Source:** Query from `bookings` table with joins to `vendors` and `services`
2. **Time Series Aggregation:**
   - Use PostgreSQL `date_trunc()` for granularity
   - Group by date bucket and aggregate counts/sums
3. **Performance:**
   - Add index on `bookings.created_at` if not exists
   - Consider materialized view for historical data
   - Cache results for 5 minutes (especially for date ranges > 30 days)
4. **Date Handling:**
   - All dates in UTC
   - Parse ISO 8601 format
   - Validate date range (max 365 days)
5. **Filters:**
   - Apply WHERE clauses for optional filters
   - vendor_id, status, city, category should be AND conditions

#### Frontend Integration

**Repository Method (Already Implemented):**
```dart
// lib/repositories/analytics_repo.dart
Future<BookingAnalytics> fetchBookingAnalytics({
  required DateTime from,
  required DateTime to,
  String granularity = 'day',
  String? vendorId,
  String? status,
  String? city,
  String? category,
}) async {
  final response = await _client.requestAdmin<Map<String, dynamic>>(
    '/admin/analytics/bookings',
    queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'granularity': granularity,
      if (vendorId != null) 'vendor_id': vendorId,
      if (status != null) 'status': status,
      if (city != null) 'city': city,
      if (category != null) 'category': category,
    },
  );
  return BookingAnalytics.fromJson(response.data!);
}
```

**UI Screen:**
- `lib/features/analytics/analytics_screen.dart` - Dashboard with charts
- Chart library: `fl_chart` package
- Will display time series line chart and summary cards

---

### 2. GET /api/v1/admin/analytics/revenue

**Purpose:** Provide revenue analytics with time series data and payment breakdowns

**Path:** `/api/v1/admin/analytics/revenue`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** `analytics:view` or `super_admin`

#### Request

**Query Parameters:**
```typescript
{
  from: string;          // ISO 8601 date (required) - "2025-10-01T00:00:00Z"
  to: string;            // ISO 8601 date (required) - "2025-10-31T23:59:59Z"
  granularity?: string;  // "day" | "week" | "month" (default: "day")
  vendor_id?: string;    // Filter by vendor UUID (optional)
  payment_method?: string; // "card" | "upi" | "wallet" | "netbanking" (optional)
  city?: string;         // Filter by city (optional)
  category?: string;     // Filter by service category (optional)
}
```

**Example Request:**
```bash
GET /api/v1/admin/analytics/revenue?from=2025-10-01T00:00:00Z&to=2025-10-31T23:59:59Z&granularity=week
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "time_series": [
      {
        "date": "2025-10-01",
        "gross_revenue_cents": 2500000,
        "net_revenue_cents": 2375000,
        "refunds_cents": 50000,
        "platform_fees_cents": 75000,
        "vendor_payouts_cents": 2300000,
        "transactions_count": 450,
        "avg_transaction_cents": 5555
      },
      {
        "date": "2025-10-08",
        "gross_revenue_cents": 2800000,
        "net_revenue_cents": 2660000,
        "refunds_cents": 45000,
        "platform_fees_cents": 95000,
        "vendor_payouts_cents": 2565000,
        "transactions_count": 520,
        "avg_transaction_cents": 5384
      }
    ],
    "summary": {
      "gross_revenue_cents": 42500000,
      "net_revenue_cents": 40375000,
      "refunds_cents": 875000,
      "platform_fees_cents": 1250000,
      "vendor_payouts_cents": 39125000,
      "transactions_count": 8450,
      "avg_transaction_cents": 5029,
      "growth_rate_percent": 12.5
    },
    "by_payment_method": [
      {
        "method": "card",
        "revenue_cents": 25000000,
        "transactions_count": 5000,
        "percentage": 58.8
      },
      {
        "method": "upi",
        "revenue_cents": 12000000,
        "transactions_count": 2500,
        "percentage": 28.2
      },
      {
        "method": "wallet",
        "revenue_cents": 5500000,
        "transactions_count": 950,
        "percentage": 13.0
      }
    ],
    "top_revenue_vendors": [
      {
        "vendor_id": "uuid",
        "vendor_name": "Premium Services Inc",
        "revenue_cents": 3500000,
        "transactions_count": 450
      }
    ],
    "top_revenue_categories": [
      {
        "category": "Home Services",
        "revenue_cents": 15000000,
        "transactions_count": 3200
      }
    ]
  },
  "meta": {
    "from": "2025-10-01T00:00:00Z",
    "to": "2025-10-31T23:59:59Z",
    "granularity": "week",
    "currency": "INR",
    "filters_applied": {
      "city": null,
      "category": null,
      "vendor_id": null,
      "payment_method": null
    }
  }
}
```

**Error Responses:**

**400 Bad Request - Invalid Date Range:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_DATE_RANGE",
    "message": "Date range cannot exceed 365 days",
    "details": {
      "from": "2024-01-01",
      "to": "2025-11-01",
      "days": 670
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
    "message": "You don't have permission to view revenue analytics",
    "required_permission": "analytics:view"
  }
}
```

#### Implementation Notes

1. **Data Source:** Query from `payments` table with joins to `bookings`, `vendors`, and `services`
2. **Revenue Calculations:**
   - `gross_revenue` = Sum of all successful payments
   - `net_revenue` = gross_revenue - refunds
   - `platform_fees` = Calculate based on commission rate
   - `vendor_payouts` = gross_revenue - platform_fees - refunds
3. **Performance:**
   - Add composite index on `(payment_status, created_at)` if not exists
   - Cache results for 15 minutes
   - Consider read replica for heavy queries
4. **Currency:**
   - All amounts in cents (smallest currency unit)
   - Add `currency` field in meta (currently INR)
   - Support future multi-currency expansion
5. **Payment Method Breakdown:**
   - Group by `payment_method` field
   - Calculate percentages of total
6. **Growth Rate:**
   - Compare with previous period (same duration)
   - Formula: `((current - previous) / previous) * 100`

#### Frontend Integration

**Repository Method (Already Implemented):**
```dart
// lib/repositories/analytics_repo.dart
Future<RevenueAnalytics> fetchRevenueAnalytics({
  required DateTime from,
  required DateTime to,
  String granularity = 'day',
  String? vendorId,
  String? paymentMethod,
  String? city,
  String? category,
}) async {
  final response = await _client.requestAdmin<Map<String, dynamic>>(
    '/admin/analytics/revenue',
    queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'granularity': granularity,
      if (vendorId != null) 'vendor_id': vendorId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (city != null) 'city': city,
      if (category != null) 'category': category,
    },
  );
  return RevenueAnalytics.fromJson(response.data!);
}
```

**UI Screen:**
- `lib/features/analytics/analytics_screen.dart` - Revenue dashboard
- Display: Area chart for revenue trend, pie chart for payment methods
- Summary cards for key metrics

---

### 3. GET /api/v1/admin/jobs/{job_id}

**Purpose:** Poll status of long-running background jobs (analytics export, bulk operations)

**Path:** `/api/v1/admin/jobs/{job_id}`  
**Method:** `GET`  
**Authentication:** Required - JWT Bearer token  
**Permissions:** Same as the operation that created the job

#### Request

**Path Parameters:**
- `job_id` (string, required) - UUID of the background job

**Example Request:**
```bash
GET /api/v1/admin/jobs/550e8400-e29b-41d4-a716-446655440000
Authorization: Bearer <admin_jwt_token>
```

#### Response

**Success Response (200 OK) - Job Pending:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "analytics_export",
    "status": "pending",
    "progress_percent": 0,
    "created_at": "2025-11-12T10:00:00Z",
    "updated_at": "2025-11-12T10:00:00Z",
    "started_at": null,
    "completed_at": null,
    "estimated_duration_seconds": 120,
    "creator_id": "admin-uuid",
    "result": null,
    "error": null,
    "metadata": {
      "report_type": "bookings",
      "from": "2025-10-01",
      "to": "2025-10-31"
    }
  }
}
```

**Success Response (200 OK) - Job Processing:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "analytics_export",
    "status": "processing",
    "progress_percent": 65,
    "created_at": "2025-11-12T10:00:00Z",
    "updated_at": "2025-11-12T10:01:30Z",
    "started_at": "2025-11-12T10:00:05Z",
    "completed_at": null,
    "estimated_duration_seconds": 120,
    "creator_id": "admin-uuid",
    "result": null,
    "error": null,
    "metadata": {
      "report_type": "bookings",
      "from": "2025-10-01",
      "to": "2025-10-31",
      "rows_processed": 6500,
      "total_rows": 10000
    }
  }
}
```

**Success Response (200 OK) - Job Succeeded:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "analytics_export",
    "status": "succeeded",
    "progress_percent": 100,
    "created_at": "2025-11-12T10:00:00Z",
    "updated_at": "2025-11-12T10:02:15Z",
    "started_at": "2025-11-12T10:00:05Z",
    "completed_at": "2025-11-12T10:02:15Z",
    "estimated_duration_seconds": 120,
    "actual_duration_seconds": 130,
    "creator_id": "admin-uuid",
    "result": {
      "file_url": "https://cdn.appydex.com/exports/bookings-2025-10.csv",
      "file_size_bytes": 2458000,
      "expires_at": "2025-11-13T10:02:15Z",
      "rows_count": 10000,
      "format": "csv"
    },
    "error": null,
    "metadata": {
      "report_type": "bookings",
      "from": "2025-10-01",
      "to": "2025-10-31"
    }
  }
}
```

**Success Response (200 OK) - Job Failed:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "analytics_export",
    "status": "failed",
    "progress_percent": 45,
    "created_at": "2025-11-12T10:00:00Z",
    "updated_at": "2025-11-12T10:01:45Z",
    "started_at": "2025-11-12T10:00:05Z",
    "completed_at": "2025-11-12T10:01:45Z",
    "estimated_duration_seconds": 120,
    "actual_duration_seconds": 100,
    "creator_id": "admin-uuid",
    "result": null,
    "error": {
      "code": "DATABASE_TIMEOUT",
      "message": "Query execution timeout after 100 seconds",
      "retryable": true
    },
    "metadata": {
      "report_type": "bookings",
      "from": "2025-10-01",
      "to": "2025-10-31"
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
    "code": "JOB_NOT_FOUND",
    "message": "Background job not found",
    "job_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": {
    "code": "PERMISSION_DENIED",
    "message": "You don't have permission to view this job",
    "required_permission": "analytics:view"
  }
}
```

#### Status Field Values

| Status | Description | Terminal? | Next Steps |
|--------|-------------|-----------|------------|
| `pending` | Job queued, not started | No | Keep polling |
| `processing` | Job actively running | No | Keep polling, show progress |
| `succeeded` | Job completed successfully | Yes | Download result |
| `failed` | Job failed with error | Yes | Show error, allow retry |
| `cancelled` | Job cancelled by user/system | Yes | N/A |

#### Implementation Notes

1. **Job Storage:**
   - Create `background_jobs` table:
   ```sql
   CREATE TABLE background_jobs (
     id UUID PRIMARY KEY,
     type VARCHAR(50) NOT NULL,
     status VARCHAR(20) NOT NULL,
     progress_percent INT DEFAULT 0,
     created_at TIMESTAMP NOT NULL,
     updated_at TIMESTAMP NOT NULL,
     started_at TIMESTAMP,
     completed_at TIMESTAMP,
     estimated_duration_seconds INT,
     actual_duration_seconds INT,
     creator_id UUID NOT NULL REFERENCES admin_users(id),
     result JSONB,
     error JSONB,
     metadata JSONB,
     INDEX idx_creator_status (creator_id, status),
     INDEX idx_status_updated (status, updated_at)
   );
   ```

2. **Job Queue:**
   - Use Redis/Celery/BullMQ for job queue
   - Or simple PostgreSQL-based queue with worker polling
   - Worker processes update `progress_percent` and `updated_at` regularly

3. **Result Storage:**
   - Store export files on S3/GCS/Azure Blob
   - Generate presigned URLs with 24-hour expiry
   - Clean up files after 7 days

4. **Permissions:**
   - Admins can only view jobs they created OR have `jobs:view_all` permission
   - Inherit permissions from the operation that created the job

5. **Polling Strategy (Frontend):**
   - Initial poll: 2 seconds
   - Exponential backoff: 2s → 3s → 5s → 10s → 10s (max)
   - Stop polling when status is terminal (succeeded/failed/cancelled)

#### Frontend Integration

**Widget (Already Implemented):**
```dart
// lib/widgets/job_poller.dart
class JobPoller extends StatefulWidget {
  final String jobId;
  final Widget Function(BackgroundJob job) builder;
  final VoidCallback? onComplete;
  
  // Polls every 2-10 seconds until job is complete
  // Shows progress indicator
  // Calls onComplete when succeeded
  // Shows error dialog when failed
}
```

**Usage Example:**
```dart
// After starting analytics export:
final jobId = await analyticsRepo.requestExport(...);

// Show polling dialog:
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => JobPoller(
    jobId: jobId,
    builder: (job) {
      if (job.status == 'succeeded') {
        return DownloadButton(url: job.result.fileUrl);
      }
      return ProgressIndicator(progress: job.progressPercent);
    },
    onComplete: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export ready!')),
      );
    },
  ),
);
```

---

## 🔒 Security & Validation

### Authentication
- All endpoints require valid JWT Bearer token
- Token must not be expired
- Token must have required permissions

### Authorization (RBAC)

| Endpoint | Required Permission | Alternative |
|----------|-------------------|-------------|
| `GET /admin/analytics/bookings` | `analytics:view` | `super_admin` |
| `GET /admin/analytics/revenue` | `analytics:view` | `super_admin` |
| `GET /admin/jobs/{job_id}` | Creator OR `jobs:view_all` | `super_admin` |

### Input Validation

**Date Range:**
- Both `from` and `to` are required
- Must be valid ISO 8601 format
- `from` must be before `to`
- Maximum range: 365 days
- Cannot query future dates

**Granularity:**
- Must be one of: `day`, `week`, `month`
- Default to `day` if not specified

**Optional Filters:**
- `vendor_id`: Valid UUID, vendor must exist
- `city`: String, max 100 chars
- `category`: String, max 100 chars
- `status`: One of predefined values
- `payment_method`: One of predefined values

### Rate Limiting

- Analytics endpoints: 60 requests per minute per admin
- Jobs endpoint: 120 requests per minute per admin (polling)
- Return `429 Too Many Requests` with:
  ```json
  {
    "error": {
      "code": "RATE_LIMIT_EXCEEDED",
      "message": "Too many requests, please slow down",
      "retry_after_seconds": 30
    }
  }
  ```

### Caching

- **Analytics endpoints:** Cache results for 5-15 minutes based on date range
  - Real-time data (today): No cache
  - Yesterday: 5 minutes
  - 7+ days ago: 15 minutes
- **Jobs endpoint:** No cache (always fetch latest status)
- Use Redis for caching with TTL

---

## 📊 Database Indexes

**Required Indexes for Performance:**

```sql
-- Bookings analytics
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_status_created ON bookings(status, created_at);
CREATE INDEX idx_bookings_vendor_created ON bookings(vendor_id, created_at);

-- Revenue analytics
CREATE INDEX idx_payments_status_created ON payments(status, created_at);
CREATE INDEX idx_payments_method_created ON payments(payment_method, created_at);
CREATE INDEX idx_payments_vendor_created ON payments(vendor_id, created_at) 
  WHERE status = 'succeeded';

-- Jobs
CREATE INDEX idx_jobs_creator_status ON background_jobs(creator_id, status);
CREATE INDEX idx_jobs_status_updated ON background_jobs(status, updated_at);
```

---

## 🧪 Testing Requirements

### Unit Tests
- [ ] Date range validation (invalid, too large, future dates)
- [ ] Granularity grouping (day, week, month)
- [ ] Revenue calculations (gross, net, fees, payouts)
- [ ] Payment method breakdown percentages
- [ ] Growth rate calculation

### Integration Tests
- [ ] Bookings analytics with real data
- [ ] Revenue analytics with real data
- [ ] Job creation and status polling
- [ ] Job progress updates
- [ ] Job completion with file URL
- [ ] Job failure handling

### Performance Tests
- [ ] Query performance with 1M+ bookings
- [ ] Query performance with 1M+ payments
- [ ] Concurrent job processing (10+ jobs)
- [ ] Cache hit rates

### Manual Testing Checklist
- [ ] Test with date range: last 7 days
- [ ] Test with date range: last 30 days
- [ ] Test with date range: last 365 days
- [ ] Test with various filters (vendor, city, category)
- [ ] Test granularity: day, week, month
- [ ] Test job polling from pending → processing → succeeded
- [ ] Test job failure scenario
- [ ] Test rate limiting (60+ requests in 1 minute)
- [ ] Test caching (same query twice)

---

## 📦 Deliverables

### Code
- [ ] Implement `GET /api/v1/admin/analytics/bookings`
- [ ] Implement `GET /api/v1/admin/analytics/revenue`
- [ ] Implement `GET /api/v1/admin/jobs/{job_id}`
- [ ] Create `background_jobs` table migration
- [ ] Add database indexes
- [ ] Set up Redis caching
- [ ] Configure job queue (Celery/BullMQ)

### Documentation
- [ ] API documentation in OpenAPI spec
- [ ] Update `/openapi/v1.json` with new endpoints
- [ ] Database schema documentation
- [ ] Job queue architecture documentation

### Testing
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] Performance tests
- [ ] Load testing report

---

## 🚀 Deployment Plan

### Prerequisites
- Redis instance for caching and job queue
- S3/GCS bucket for export file storage
- Worker processes for background jobs

### Rollout Steps
1. Deploy database migrations
2. Add Redis configuration
3. Deploy API endpoints
4. Start background workers
5. Test with staging data
6. Deploy to production
7. Monitor error rates and performance

### Monitoring
- Track endpoint response times (p50, p95, p99)
- Monitor job queue depth
- Track job success/failure rates
- Set up alerts for:
  - Response time > 5s
  - Job queue > 100 pending
  - Job failure rate > 10%
  - Cache hit rate < 70%

---

## 📞 Questions for Backend Team

1. **Job Queue:** Which job queue system are you using? (Celery, BullMQ, PostgreSQL-based, other?)
2. **File Storage:** Where should export files be stored? (S3, GCS, Azure, local?)
3. **Retention:** How long should we keep completed jobs? (Suggest 7 days)
4. **Worker Count:** How many worker processes for background jobs?
5. **Redis:** Do you have Redis available? Or should we use alternative caching?
6. **Currency:** Currently assuming INR - need multi-currency support?

---

## ✅ Acceptance Criteria

### Functional
- [x] All 3 endpoints return correct data structure
- [x] Date range filtering works correctly
- [x] Granularity grouping (day/week/month) works
- [x] Optional filters apply correctly
- [x] Job polling shows accurate progress
- [x] Export files are downloadable

### Performance
- [x] Response time < 3s for 90 days of data
- [x] Response time < 5s for 365 days of data
- [x] Job processing completes within 2 minutes for typical exports
- [x] Cache hit rate > 70%

### Security
- [x] RBAC enforced on all endpoints
- [x] Rate limiting works
- [x] Export URLs expire after 24 hours
- [x] Admins can only access their own jobs (unless admin)

---

## 📚 Related Documentation

- Frontend Analytics Repository: `lib/repositories/analytics_repo.dart`
- Frontend Analytics Models: `lib/models/analytics.dart`
- Frontend Job Poller Widget: `lib/widgets/job_poller.dart`
- Frontend API Alignment: `docs/api/FRONTEND_BACKEND_API_ALIGNMENT.md`

---

**Created by:** Frontend Team  
**For:** Backend Team  
**Date:** November 12, 2025  
**Version:** 1.0
