# Frontend-Backend API Alignment Report

**Generated:** November 8, 2025  
**Backend API Version:** v1  
**Frontend Version:** 2.1.0  
**Status:** 🟡 **Partial Coverage - Implementation in Progress**

---

## Executive Summary

This document maps the backend API contract (55+ endpoints) to the frontend Flutter implementation, identifying coverage gaps and required implementations.

### Overall Status

| Category | Total Endpoints | Implemented | Missing | Coverage % |
|----------|----------------|-------------|---------|------------|
| **Authentication** | 6 | 4 | 2 | 67% |
| **User Accounts** | 6 | 5 | 1 | 83% |
| **Roles & Permissions** | 3 | 3 | 0 | 100% |
| **Background Jobs** | 4 | 1 | 3 | 25% |
| **Vendor Management** | 5 | 5 | 0 | 100% |
| **Payments** | 3 | 3 | 0 | 100% |
| **Subscription Plans** | 4 | 4 | 0 | 100% |
| **Service Management** | 2 | 2 | 0 | 100% |
| **Service Types** | 2 | 2 | 0 | 100% |
| **Service Type Requests** | 3 | 3 | 0 | 100% |
| **Subscriptions** | 2 | 2 | 0 | 100% |
| **Invoices** | 2 | 2 | 0 | 100% |
| **Refunds** | 3 | 0 | 3 | 0% |
| **Reviews & Moderation** | 9 | 6 | 3 | 67% |
| **Campaigns** | 2 | 2 | 0 | 100% |
| **Referrals** | 1 | 0 | 1 | 0% |
| **Analytics** | 6 | 3 | 3 | 50% |
| **Audit Logs** | 1 | 1 | 0 | 100% |
| **System Management** | 5 | 2 | 3 | 40% |
| **TOTALS** | **69** | **50** | **19** | **72%** |

---

## 1. Authentication (`/api/v1/admin/auth`)

**Repository:** `lib/core/auth/auth_repository.dart`  
**Coverage:** 🟡 67% (4/6 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/request-otp` | POST | ❌ Not implemented | 🔴 Missing |
| `/login` | POST | ✅ `auth_repository.dart:login()` | ✅ Done |
| `/refresh` | POST | ✅ `api_client.dart:forceRefresh()` | ✅ Done |
| `/logout` | POST | ✅ `auth_service.dart:logout()` | ✅ Done |
| `/me` | GET | ✅ `auth_service.dart` (implicit) | ✅ Done |
| `/change-password` | POST | ❌ Not implemented | 🔴 Missing |

**Required Actions:**
- [ ] Implement `requestOtp()` method in `OtpRepository`
- [ ] Implement `changePassword()` method in `AuthRepository`

---

## 2. User Accounts Management (`/api/v1/admin/accounts`)

**Repository:** `lib/repositories/admin_user_repo.dart`  
**Coverage:** 🟢 83% (5/6 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/users` | GET | ✅ `admin_user_repo.dart:list()` | ✅ Done |
| `/users/{user_id}` | GET | ✅ `admin_user_repo.dart:getById()` | ✅ Done |
| `/users` | POST | ✅ `admin_user_repo.dart:create()` | ✅ Done |
| `/users/{user_id}` | PUT | ✅ `admin_user_repo.dart:update()` | ✅ Done |
| `/users/{user_id}` | DELETE | ✅ `admin_user_repo.dart:delete()` | ✅ Done |
| `/{user_id}` | PATCH | ✅ `admin_user_repo.dart:toggleActive()` | ✅ Done |

**Note:** Backend contract shows `/admin/accounts/users` but implementation uses `/admin/accounts` directly.

**Required Actions:**
- [x] All user account endpoints implemented

---

## 3. Roles & Permissions (`/api/v1/admin/roles`)

**Repository:** `lib/repositories/role_repo.dart`  
**Coverage:** 🟢 100% (3/3 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `role_repo.dart:list()` | ✅ Done |
| `/assign` | POST | ✅ `role_repo.dart:assignRole()` | ✅ Done |
| `/{user_id}/{role}` | DELETE | ✅ `role_repo.dart:revokeRole()` | ✅ Done |

---

## 4. Background Jobs (`/api/v1/admin/jobs`)

**Repository:** ❌ **MISSING** - No dedicated repository  
**Widget:** `lib/widgets/job_poller.dart` (polling logic only)  
**Coverage:** 🔴 25% (1/4 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ❌ Not implemented | 🔴 Missing |
| `/{job_id}` | GET | ✅ `job_poller.dart` (polling only) | 🟡 Partial |
| `/{job_id}/cancel` | POST | ❌ Not implemented | 🔴 Missing |
| `/{job_id}` | DELETE | ❌ Not implemented | 🔴 Missing |

**Required Actions:**
- [ ] Create `lib/repositories/job_repo.dart` with full CRUD operations
- [ ] Add `list()` method for job listing with pagination
- [ ] Add `cancel()` method to cancel jobs
- [ ] Add `delete()` method to remove completed jobs
- [ ] Integrate with existing `JobPoller` widget

---

## 5. Vendor Management (`/api/v1/admin/vendors`)

**Repository:** `lib/repositories/vendor_repo.dart`  
**Coverage:** 🟢 100% (5/5 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `vendor_repo.dart:list()` | ✅ Done |
| `/{vendor_id}` | GET | ✅ `vendor_repo.dart:getById()` | ✅ Done |
| `/{vendor_id}/approve` | POST | ✅ `vendor_repo.dart:approve()` | ✅ Done |
| `/{vendor_id}/reject` | POST | ✅ `vendor_repo.dart:reject()` | ✅ Done |
| `/{vendor_id}/suspend` | POST | ✅ `vendor_repo.dart:suspend()` | ✅ Done |

---

## 6. Payments & Transactions (`/api/v1/admin/payments`)

**Repository:** `lib/repositories/payment_repo.dart`  
**Coverage:** 🟢 100% (3/3 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `payment_repo.dart:list()` | ✅ Done |
| `/{payment_id}` | GET | ✅ `payment_repo.dart:getById()` | ✅ Done |
| `/export` | GET | ✅ Analytics export flow | ✅ Done |

**Note:** Refund functionality is in payment_repo but could be moved to dedicated refund_repo.

---

## 7. Subscription Plans (`/api/v1/admin/plans`)

**Repository:** `lib/repositories/plan_repo.dart`  
**Coverage:** 🟢 100% (4/4 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `plan_repo.dart:list()` | ✅ Done |
| `/` | POST | ✅ `plan_repo.dart:create()` | ✅ Done |
| `/{plan_id}` | PUT | ✅ `plan_repo.dart:update()` | ✅ Done |
| `/{plan_id}` | DELETE | ✅ `plan_repo.dart:delete()` | ✅ Done |

---

## 8. Service Management (`/api/v1/admin/services`)

**Repository:** `lib/repositories/service_repo.dart`  
**Coverage:** 🟢 100% (2/2 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `service_repo.dart:list()` | ✅ Done |
| `/{service_id}/status` | PATCH | ✅ `service_repo.dart:updateStatus()` | ✅ Done |

---

## 9. Service Types (`/api/v1/admin/service-types`)

**Repository:** `lib/repositories/service_type_repo.dart`  
**Coverage:** 🟢 100% (2/2 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `service_type_repo.dart:list()` | ✅ Done |
| `/` | POST | ✅ `service_type_repo.dart:create()` | ✅ Done |

---

## 10. Service Type Requests (`/api/v1/admin/service-type-requests`)

**Repository:** `lib/repositories/service_type_request_repo.dart`  
**Coverage:** 🟢 100% (3/3 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `service_type_request_repo.dart:list()` | ✅ Done |
| `/{request_id}/approve` | POST | ✅ `service_type_request_repo.dart:approve()` | ✅ Done |
| `/{request_id}/reject` | POST | ✅ `service_type_request_repo.dart:reject()` | ✅ Done |

---

## 11. Subscriptions (`/api/v1/admin/subscriptions`)

**Repository:** `lib/repositories/subscription_repo.dart`  
**Coverage:** 🟢 100% (2/2 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `subscription_repo.dart:list()` | ✅ Done |
| `/{subscription_id}/extend` | POST | ✅ `subscription_repo.dart:extend()` | ✅ Done |

---

## 12. Invoices (`/api/v1/admin/invoices`)

**Repository:** `lib/repositories/invoice_repo.dart`  
**Coverage:** 🟢 100% (2/2 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `invoice_repo.dart:list()` | ✅ Done |
| `/{invoice_id}/download` | GET | ✅ `invoice_repo.dart:download()` | ✅ Done |

---

## 13. Refunds (`/api/v1/admin/refunds`)

**Repository:** ❌ **MISSING** - Refund logic in `payment_repo.dart`  
**Coverage:** 🔴 0% (0/3 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ❌ Not implemented | 🔴 Missing |
| `/{refund_id}/approve` | POST | 🟡 `payment_repo.dart:refundPayment()` | 🟡 Partial |
| `/{refund_id}/reject` | POST | ❌ Not implemented | 🔴 Missing |

**Current State:**
- Refund processing exists in `payment_repo.dart:refundPayment()` but follows different pattern
- No dedicated refund request listing
- No approve/reject workflow for refund requests

**Required Actions:**
- [ ] Create `lib/repositories/refund_repo.dart`
- [ ] Add `list()` method to get refund requests
- [ ] Add `approve()` method to approve refunds
- [ ] Add `reject()` method to reject refunds
- [ ] Update payment_repo to use refund_repo

---

## 14. Reviews & Moderation (`/api/v1/admin/reviews`)

**Repository:** `lib/repositories/reviews_repo.dart`  
**Coverage:** 🟡 67% (6/9 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `reviews_repo.dart:list()` | ✅ Done |
| `/{review_id}` | GET | ✅ `reviews_repo.dart:getById()` | ✅ Done |
| `/{review_id}/hide` | POST | ✅ `reviews_repo.dart:hide()` | ✅ Done |
| `/{review_id}` | DELETE | ✅ `reviews_repo.dart:remove()` | ✅ Done |
| `/{review_id}/restore` | POST | ✅ `reviews_repo.dart:restore()` | ✅ Done |
| `/takedown-requests` | GET | ❌ Not implemented | 🔴 Missing |
| `/takedown-requests/{id}` | GET | ❌ Not implemented | 🔴 Missing |
| `/takedown-requests/{id}/resolve` | POST | ❌ Not implemented | 🔴 Missing |
| `/{review_id}/approve` | POST | ✅ `reviews_repo.dart:approve()` | ⚠️ Deprecated |

**Note:** Backend removed `/approve` endpoint per policy change (reviews go live immediately).

**Required Actions:**
- [ ] Add `listTakedownRequests()` method
- [ ] Add `getTakedownRequest()` method
- [ ] Add `resolveTakedownRequest()` method
- [ ] Remove deprecated `approve()` method

---

## 15. Campaigns (`/api/v1/admin/campaigns`)

**Repository:** `lib/repositories/campaign_repo.dart`  
**Coverage:** 🟢 100% (2/2 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ✅ `campaign_repo.dart:list()` | ✅ Done |
| `/` | POST | ✅ `campaign_repo.dart:create()` | ✅ Done |

---

## 16. Referrals (`/api/v1/admin/referrals`)

**Repository:** ❌ **MISSING**  
**Coverage:** 🔴 0% (0/1 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/` | GET | ❌ Not implemented | 🔴 Missing |

**Required Actions:**
- [ ] Create `lib/repositories/referral_repo.dart`
- [ ] Add `list()` method with pagination and filters

---

## 17. Analytics (`/api/v1/admin/analytics`)

**Repository:** `lib/repositories/analytics_repo.dart`  
**Coverage:** 🟡 50% (3/6 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/top-searches` | GET | ✅ `analytics_repo.dart:fetchTopSearches()` | ✅ Done |
| `/ctr` | GET | ✅ `analytics_repo.dart:fetchCtrSeries()` | ✅ Done |
| `/bookings` | GET | ❌ Not implemented | 🔴 Missing |
| `/revenue` | GET | ❌ Not implemented | 🔴 Missing |
| `/export` | POST | ✅ `analytics_repo.dart:requestExport()` | ✅ Done |

**Required Actions:**
- [ ] Add `fetchBookingAnalytics()` method
- [ ] Add `fetchRevenueAnalytics()` method

---

## 18. Audit Logs (`/api/v1/admin/audit`)

**Repository:** `lib/repositories/audit_repo.dart`  
**Coverage:** 🟢 100% (1/1 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/logs` | GET | ✅ `audit_repo.dart:list()` | ✅ Done |

---

## 19. System Management (`/api/v1/admin/system`)

**Repository:** `lib/repositories/system_repo.dart`  
**Coverage:** 🟡 40% (2/5 endpoints)

| Endpoint | Method | Frontend Implementation | Status |
|----------|--------|------------------------|--------|
| `/health` | GET | ❌ Not implemented | 🔴 Missing |
| `/backup` | POST | ❌ Not implemented | 🔴 Missing |
| `/restore` | POST | ❌ Not implemented | 🔴 Missing |
| `/backups` | GET | ❌ Not implemented | 🔴 Missing |
| `/ephemeral-stats` | GET | ✅ `system_repo.dart:getEphemeralStats()` | ✅ Done |
| `/cleanup` | POST | ✅ `system_repo.dart:triggerCleanup()` | ✅ Done |

**Required Actions:**
- [ ] Add `getSystemHealth()` method
- [ ] Add `triggerBackup()` method
- [ ] Add `restoreFromBackup()` method
- [ ] Add `listBackups()` method

---

## Cross-Cutting Concerns

### 1. Idempotency Key Generation

**Status:** 🟢 Implemented  
**Location:** `lib/core/utils/idempotency.dart`

The frontend already has UUID v4 idempotency key generation via `idempotentOptions()`. This is used in:
- ✅ `admin_user_repo.dart` (create, update, delete, toggleActive)
- ✅ `vendor_repo.dart` (approve, reject, suspend)
- ✅ `payment_repo.dart` (refundPayment)

**Required Actions:**
- [ ] Ensure all mutating operations use `idempotentOptions()`
- [ ] Add idempotency to reviews moderation (hide, remove, restore)
- [ ] Add idempotency to new endpoints (jobs, refunds, takedowns)

---

### 2. Error Handling with Trace IDs

**Status:** 🔴 Not Implemented

Backend returns trace IDs in error responses:
```json
{
  "code": "VALIDATION_ERROR",
  "message": "Invalid input",
  "trace_id": "req_abc123"
}
```

**Required Actions:**
- [ ] Update `ApiClient` to extract `trace_id` from error responses
- [ ] Update `AppHttpException` to include `traceId` field
- [ ] Display trace ID in error dialogs for debugging

---

### 3. Rate Limit Handling

**Status:** 🔴 Not Implemented

Backend will return rate limit headers:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 987
X-RateLimit-Reset: 1699456800
```

**Required Actions:**
- [ ] Add rate limit header parsing to `ApiClient`
- [ ] Implement exponential backoff for 429 responses
- [ ] Display rate limit warnings to users
- [ ] Add rate limit state provider for UI feedback

---

### 4. CSRF Token Handling

**Status:** 🟢 Implemented  
**Location:** `lib/core/api_client.dart`

CSRF tokens are already handled via cookies and `withCredentials: true` for web builds.

**Note:** Backend contract mentions `X-CSRF-Token` header requirement, but current implementation uses cookie-based CSRF protection.

**Required Actions:**
- [ ] Verify CSRF implementation matches backend expectations
- [ ] Add explicit `X-CSRF-Token` header if required by backend

---

## Implementation Priority

### P0 - Critical (Production Blockers)

1. **Background Jobs Repository** - Required for export functionality
2. **Refund Management** - Critical for payment operations
3. **Review Takedown Requests** - Required for review moderation workflow
4. **System Health Endpoint** - Required for monitoring dashboard

### P1 - High Priority

5. **Analytics Enhancements** - Booking and revenue analytics
6. **Change Password** - User account security
7. **Request OTP** - Authentication flow completion
8. **Referrals Repository** - Marketing features

### P2 - Medium Priority

9. **System Backup/Restore** - Admin operations
10. **Error Handling Enhancements** - Trace ID tracking
11. **Rate Limit Handling** - API protection

---

## Testing Recommendations

### Integration Tests Required

- [ ] Authentication flow (login, refresh, logout, change password)
- [ ] Background job polling and cancellation
- [ ] Review takedown request workflow
- [ ] Refund request approval/rejection
- [ ] Analytics data fetching and export
- [ ] System health monitoring
- [ ] Idempotency key handling for all critical operations
- [ ] Rate limit response handling

### Manual Testing Checklist

- [ ] Verify all endpoints against localhost:16110
- [ ] Test error handling with trace IDs
- [ ] Validate CSRF token handling
- [ ] Test job polling with long-running exports
- [ ] Verify rate limit headers are received
- [ ] Test idempotency key behavior (duplicate operations)

---

## Migration Notes

### Breaking Changes from Backend

1. **Review Approval Removed** - Backend removed `POST /admin/reviews/{review_id}/approve`
   - Frontend has `reviews_repo.dart:approve()` method that should be removed
   - Reviews now go live immediately (no approval workflow)

2. **User Accounts Path** - Contract shows `/admin/accounts/users` but implementation uses `/admin/accounts`
   - Verify correct path with backend team

3. **Analytics Routes** - Backend moved analytics from `/analytics/*` to `/admin/analytics/*`
   - Frontend already uses correct `/admin/analytics/*` paths

---

## Recommended File Structure Changes

```
lib/repositories/
├── auth/
│   ├── auth_repository.dart ✅
│   ├── otp_repository.dart ✅
│   └── token_storage.dart ✅
├── admin/
│   ├── admin_user_repo.dart ✅
│   ├── role_repo.dart ✅
│   └── audit_repo.dart ✅
├── vendors/
│   ├── vendor_repo.dart ✅
│   └── referral_repo.dart ❌ NEW
├── services/
│   ├── service_repo.dart ✅
│   ├── service_type_repo.dart ✅
│   └── service_type_request_repo.dart ✅
├── payments/
│   ├── payment_repo.dart ✅
│   ├── refund_repo.dart ❌ NEW
│   ├── invoice_repo.dart ✅
│   └── subscription_repo.dart ✅
├── content/
│   ├── reviews_repo.dart ✅ (enhance)
│   └── campaign_repo.dart ✅
├── analytics/
│   └── analytics_repo.dart ✅ (enhance)
├── system/
│   ├── system_repo.dart ✅ (enhance)
│   └── job_repo.dart ❌ NEW
└── admin_exceptions.dart ✅
```

---

## Summary

**Overall Coverage:** 72% (50/69 endpoints implemented)

**Missing Repositories:**
1. Background Jobs Repository (4 endpoints)
2. Refund Repository (3 endpoints)
3. Referrals Repository (1 endpoint)

**Repositories Requiring Enhancement:**
1. Auth Repository (2 missing endpoints)
2. Reviews Repository (3 missing endpoints)
3. Analytics Repository (2 missing endpoints)
4. System Repository (4 missing endpoints)

**Estimated Implementation Time:**
- P0 Critical: 2-3 days
- P1 High Priority: 2 days
- P2 Medium Priority: 1-2 days
- **Total:** ~5-7 days for 100% coverage

---

**Next Steps:**
1. Review this alignment with team
2. Prioritize P0 implementations
3. Create feature branches for each repository
4. Implement missing endpoints
5. Add comprehensive tests
6. Update API documentation
