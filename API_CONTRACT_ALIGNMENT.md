# API Contract Alignment - AppyDex Admin Frontend

**Date:** November 3, 2025  
**Purpose:** Map current implementation to official backend API contract

---

## ✅ CURRENTLY IMPLEMENTED & ALIGNED

### AUTH / SESSION

| Endpoint | Status | Frontend Implementation | Notes |
|----------|--------|------------------------|-------|
| `POST /auth/login` | ⚠️ **MISALIGNED** | Using `/auth/admin/login` | **ACTION: Update to `/auth/login`** |
| `POST /auth/refresh` | ✅ **ALIGNED** | `auth_service.dart` | Correct endpoint |
| `POST /auth/logout` | ✅ **ALIGNED** | `auth_service.dart` | Correct endpoint |
| `POST /auth/change-password` | ⚠️ **CUSTOM** | `change_password_screen.dart` | Not in contract, may need `/auth/reset-password` |

**Required Changes:**
1. Change login endpoint from `/auth/admin/login` → `/auth/login`
2. Verify change password uses correct endpoint

---

### ADMIN USERS & ROLES (RBAC)

| Endpoint | Status | Implementation | File |
|----------|--------|----------------|------|
| `GET /admin/users` | ✅ **ALIGNED** | ✅ Complete | `admin_user_repo.dart` |
| `POST /admin/users` | ✅ **ALIGNED** | ✅ Complete | `admin_user_repo.dart` |
| `GET /admin/users/{id}` | ✅ **ALIGNED** | ✅ Complete | `admin_user_repo.dart` |
| `PATCH /admin/users/{id}` | ✅ **ALIGNED** | ✅ Complete | `admin_user_repo.dart` |
| `DELETE /admin/users/{id}` | ✅ **ALIGNED** | ✅ Complete | `admin_user_repo.dart` |
| `POST /admin/impersonate/{user_id}` | ❌ **MISSING** | Not implemented | **TODO** |
| `GET /admin/roles` | ❌ **MISSING** | Mock data only | **TODO** |

**UI Screens:**
- ✅ Admin Users List (`admins_list_screen.dart`)
- ✅ Admin Form Dialog (`admin_form_dialog.dart`)

**Notes:**
- All admin endpoints use correct paths
- Idempotency properly implemented
- Pagination working

---

### VENDORS

| Endpoint | Status | Implementation | File |
|----------|--------|----------------|------|
| `GET /admin/vendors` | ✅ **ALIGNED** | ✅ Complete | `vendor_repo.dart` |
| `GET /admin/vendors/{id}` | ✅ **ALIGNED** | ✅ Complete | `vendor_repo.dart` |
| `PATCH /admin/vendors/{id}` | ✅ **ALIGNED** | ✅ Complete | `vendor_repo.dart` |
| `POST /admin/vendors/{id}/verify` | ✅ **ALIGNED** | ✅ Complete | `vendor_repo.dart` |
| `POST /admin/vendors/bulk_verify` | ✅ **ALIGNED** | ✅ Complete (as `bulk-verify`) | `vendor_repo.dart` |
| `POST /admin/vendors/{id}/suspend` | ❌ **MISSING** | Not implemented | **TODO** |

**UI Screens:**
- ✅ Vendors List (`vendors_list_screen.dart`)
- ✅ Vendor Detail (`vendor_detail_screen.dart`)
- ✅ Vendor Documents Dialog (`vendor_documents_dialog.dart`)
- ✅ Approve/Reject Dialogs (`vendor_approval_dialogs.dart`)

**Notes:**
- Verify endpoint uses `POST /admin/vendors/{id}/verify` ✅
- Bulk verify uses `/admin/vendors/bulk-verify` (contract says `bulk_verify`) - minor naming difference
- Need to add suspend functionality

---

### SERVICES (CATALOG)

| Endpoint | Status | Implementation | File |
|----------|--------|----------------|------|
| `GET /admin/services` | ✅ **ALIGNED** | ✅ Complete | `service_repo.dart` |
| `POST /admin/services` | ✅ **ALIGNED** | ✅ Complete | `service_repo.dart` |
| `PATCH /admin/services/{id}` | ✅ **ALIGNED** | ✅ Complete | `service_repo.dart` |
| `DELETE /admin/services/{id}` | ✅ **ALIGNED** | ✅ Complete | `service_repo.dart` |

**UI Screens:**
- ✅ Services List (`services_list_screen.dart`)
- ✅ Service Form Dialog (`service_form_dialog.dart`)

**Notes:**
- All service endpoints correct
- Category endpoint at `/admin/services/categories` (fallback to mock)

---

### SUBSCRIPTIONS & BILLING

| Endpoint | Status | Implementation | File |
|----------|--------|----------------|------|
| `GET /admin/subscriptions/plans` | ❌ **MISSING** | Not implemented | **TODO** |
| `POST /admin/subscriptions/plans` | ❌ **MISSING** | Not implemented | **TODO** |
| `PATCH /admin/subscriptions/plans/{id}` | ❌ **MISSING** | Not implemented | **TODO** |
| `POST /admin/subscriptions/plans/{id}/activate` | ❌ **MISSING** | Not implemented | **TODO** |
| `GET /admin/payments` | ❌ **MISSING** | Not implemented | **TODO** |
| `POST /admin/payments/{id}/refund` | ❌ **MISSING** | Not implemented | **TODO** |
| `GET /admin/invoices/{id}` | ❌ **MISSING** | Not implemented | **TODO** |

**Current Implementation:**
- Only `GET /admin/subscriptions` implemented (vendor subscriptions list)
- No subscription plans management
- No payments or refunds

---

### BOOKINGS & ORDERS

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/bookings` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `GET /admin/bookings/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `PATCH /admin/bookings/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### REVIEWS & MODERATION

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/reviews` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `PATCH /admin/reviews/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/reviews/{id}/flag` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### USERS (END USERS)

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/endusers` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `GET /admin/endusers/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `PATCH /admin/endusers/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/endusers/{id}/anonymize` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### REFERRALS & PROMOTIONS

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/referrals` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/referrals/campaigns` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `PATCH /admin/referrals/{id}/resolve` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### ANALYTICS (MONGO-BACKED)

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/analytics/top_searches` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `GET /admin/analytics/ctr` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/analytics/export` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `GET /admin/analytics/events_raw` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### AUDIT & JOBS

| Endpoint | Status | Implementation | File |
|----------|--------|----------------|------|
| `GET /admin/audit` | ⚠️ **MISALIGNED** | Using `/admin/audit-events` | `audit_repo.dart` |
| `GET /admin/jobs/{id}` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/jobs/{id}/cancel` | ❌ **NOT IMPLEMENTED** | **TODO** |

**Required Changes:**
1. Update audit endpoint from `/admin/audit-events` → `/admin/audit`

---

### SYSTEM / HEALTH / SUDO TASKS

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/system/health` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/system/backup` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/system/restore` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### NOTIFICATIONS & TEMPLATES

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `GET /admin/notifications/templates` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/notifications/send` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

### FILE UPLOAD FLOW

| Endpoint | Status | Implementation |
|----------|--------|----------------|
| `POST /admin/uploads/presign` | ❌ **NOT IMPLEMENTED** | **TODO** |
| `POST /admin/uploads/complete` | ❌ **NOT IMPLEMENTED** | **TODO** |

---

## 🔧 IMMEDIATE REQUIRED FIXES

### Priority 1: Critical Path Alignment

1. **Login Endpoint** - HIGH PRIORITY
   ```dart
   // Current (WRONG):
   '/auth/admin/login'
   
   // Required (CORRECT):
   '/auth/login'
   ```
   **File:** `lib/core/auth/auth_service.dart` line 29

2. **Audit Endpoint** - MEDIUM PRIORITY
   ```dart
   // Current (WRONG):
   '/admin/audit-events'
   
   // Required (CORRECT):
   '/admin/audit'
   ```
   **File:** `lib/repositories/audit_repo.dart` line 39

3. **Bulk Verify Endpoint** - LOW PRIORITY (minor)
   ```dart
   // Current:
   '/admin/vendors/bulk-verify'
   
   // Contract says:
   '/admin/vendors/bulk_verify'
   ```
   **File:** `lib/repositories/vendor_repo.dart` line 143

---

## 📊 IMPLEMENTATION STATUS

### Completed (Phase A - 40%)
- ✅ **Auth:** Login, logout, refresh, session management
- ✅ **Admin Users:** Full CRUD, list, create, edit, delete, toggle active
- ✅ **Services:** Full CRUD, categories, visibility management
- ✅ **Vendors:** List, detail, approve, reject, documents, bulk approve
- ✅ **Audit:** List audit logs (endpoint name needs fix)
- ✅ **Subscriptions:** List vendor subscriptions (basic)

### Not Implemented (Phase B & C - 60%)
- ❌ **Subscription Plans:** CRUD for plans, pricing, activation
- ❌ **Payments & Refunds:** List payments, process refunds, invoices
- ❌ **Bookings:** List, view, update bookings
- ❌ **Reviews:** Moderation, flagging
- ❌ **End Users:** User management, anonymization
- ❌ **Referrals:** Campaign management
- ❌ **Analytics:** Top searches, CTR, exports
- ❌ **Jobs:** Background job monitoring
- ❌ **System:** Health checks, backups, restore
- ❌ **Notifications:** Template management, sending
- ❌ **File Uploads:** Presigned URL flow
- ❌ **Impersonation:** Admin impersonation

---

## 🎯 RESPONSE FORMAT ALIGNMENT

### Current Implementation
Our API client expects:
```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "page_size": 25
}
```

### Contract Specifies
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total": 100,
    "total_pages": 4
  }
}
```

**ACTION REQUIRED:** Update `Pagination` class to handle both formats or migrate to contract format.

---

## 🔑 PERMISSIONS SYSTEM

### Contract Specifies
Login response includes:
```json
{
  "me": {
    "permissions": ["users:create", "vendors:verify", ...]
  }
}
```

### Current Implementation
Using simple role-based checks:
```dart
if (currentRole == AdminRole.superAdmin) { ... }
```

**ACTION REQUIRED:** Implement granular permission system based on `permissions[]` array.

---

## 🔐 IDEMPOTENCY IMPLEMENTATION

### Status: ✅ WELL IMPLEMENTED

Our current implementation:
```dart
import '../core/utils/idempotency.dart';

options: idempotentOptions()  // Generates UUID Idempotency-Key
```

**Files using idempotency:**
- ✅ `admin_user_repo.dart` - All mutations
- ✅ `service_repo.dart` - All mutations
- ✅ `vendor_repo.dart` - All mutations

**Matches contract:** ✅ Header format: `Idempotency-Key: <uuid-v4>`

---

## 📝 NEXT STEPS

### Week 1 Fixes (Critical)
1. Update login endpoint path
2. Update audit endpoint path
3. Test all existing endpoints against contract

### Week 2-3 (Phase B)
1. Implement subscription plans management
2. Implement payments & refunds
3. Implement bookings management

### Week 4+ (Phase C)
1. Reviews moderation
2. End users management
3. Analytics dashboards
4. Background jobs monitoring
5. System admin tools

---

## 🧪 TESTING CHECKLIST

- [ ] Login with `/auth/login`
- [ ] Admin users CRUD
- [ ] Services CRUD  
- [ ] Vendors list, detail, approve, reject
- [ ] Documents viewing
- [ ] Bulk operations
- [ ] Idempotency on all mutations
- [ ] Pagination working
- [ ] Error handling
- [ ] Session refresh

---

## 📌 NOTES FOR BACKEND TEAM

**Confirm these endpoints exist:**
- `POST /auth/login` (not /auth/admin/login)
- `GET /admin/audit` (not /admin/audit-events)
- `POST /admin/vendors/bulk_verify` (we use bulk-verify)

**Verify response formats match:**
- Login response includes `me.permissions[]`
- List endpoints return `data` + `meta` (not `items` + pagination fields)

---

**Status:** Frontend is ~40% aligned with contract. Core features (admin, services, vendors) work but need endpoint path fixes. Major features (payments, bookings, reviews, analytics) not yet implemented.
