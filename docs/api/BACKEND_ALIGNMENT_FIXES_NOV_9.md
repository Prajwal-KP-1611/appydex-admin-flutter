# Backend API Alignment Fixes - November 9, 2025

## Critical Fixes Applied

### 1. Response Wrapper Auto-Unwrapping ✅
**Problem**: Backend returns `{"success": true, "data": {...}}` but frontend was expecting unwrapped data.

**Solution**: Added response interceptor in `api_client.dart` to automatically unwrap the `data` field.

```dart
// In _onResponse interceptor
if (response.data is Map<String, dynamic>) {
  final data = response.data as Map<String, dynamic>;
  if (data.containsKey('success') && data.containsKey('data')) {
    response.data = data['data'];
  }
}
```

**Impact**: All repositories now work without manual unwrapping.

---

### 2. Permission Format Normalization ✅
**Problem**: Backend uses dots (`analytics.view`) but frontend checks colons (`analytics:view`).

**Solution**: Added normalization in `permissions.dart`:
```dart
session.permissions!.map((p) => p.replaceAll('.', ':')).toSet()
```

**Impact**: Permission checks now work correctly.

---

### 3. Session Validation Fix ✅
**Problem**: `isValid` required both `accessToken` and `refreshToken`, but refresh token is in cookie.

**Solution**: Changed validation to only require `accessToken`:
```dart
bool get isValid => accessToken.isNotEmpty;
```

**Impact**: Login now succeeds even without refresh token in response body.

---

## Known Backend Issues (From Curl Testing)

### Analytics Endpoints
- ❌ **Double "admin" in path**: `/api/v1/admin/admin/analytics/*`
- ❌ **dashboard-summary returns INTERNAL_ERROR**
- ✅ Individual endpoints work: `/admin/admin/analytics/bookings`, `/admin/admin/analytics/ctr`

### Reviews Endpoint
- ❌ `/api/v1/admin/reviews` returns INTERNAL_ERROR (trace_id: 1729d470146740d6a649aace651004ba)

### System Health
- ⚠️ PostgreSQL status shows "unhealthy" (SQL expression warning)
- ✅ Redis, MongoDB, Celery working

### Pagination Formats (Inconsistent)
1. **Format A** (accounts, service-types): `{"items": [], "total": 0, "skip": 0, "limit": 100}`
2. **Format B** (vendors): `{"items": [], "meta": {"total": 0, "page": 1, "page_size": 20}}`
3. **Format C** (jobs): `{"data": [], "meta": {"page": 1, "total": 1}}`

---

## Frontend Adjustments Needed

### 1. Analytics Repository
Update base path to include double "admin":
```dart
// OLD: '/admin/analytics/top-searches'
// NEW: '/admin/admin/analytics/top-searches'
```

### 2. Pagination Handling
Create flexible pagination parser to handle all three formats:
```dart
class PaginationResponse<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;
  
  factory PaginationResponse.fromJson(Map<String, dynamic> json) {
    // Handle Format A
    if (json.containsKey('items') && json.containsKey('total')) {
      return PaginationResponse(
        items: json['items'],
        total: json['total'],
        skip: json['skip'] ?? 0,
        limit: json['limit'] ?? 100,
      );
    }
    // Handle Format B
    if (json.containsKey('meta')) {
      final meta = json['meta'];
      return PaginationResponse(
        items: json['items'] ?? json['data'],
        total: meta['total'],
        skip: (meta['page'] - 1) * meta['page_size'],
        limit: meta['page_size'],
      );
    }
    // Handle Format C
    if (json.containsKey('data')) {
      final meta = json['meta'];
      return PaginationResponse(
        items: json['data'],
        total: meta['total'],
        skip: (meta['page'] - 1) * meta['page_size'],
        limit: meta['page_size'],
      );
    }
    throw Exception('Unknown pagination format');
  }
}
```

### 3. Service Type IDs
Change from `int` to `String` (UUIDs):
```dart
class ServiceType {
  final String id; // Changed from int
  // ...
}
```

---

## Testing Checklist

- [x] Login with OTP
- [x] Permissions display correctly
- [ ] Create admin user
- [ ] List admin users
- [ ] Analytics dashboard loads
- [ ] Service types CRUD operations
- [ ] Plans CRUD operations
- [ ] Vendors list
- [ ] Payments list
- [ ] Subscriptions list
- [ ] Jobs list
- [ ] Referrals tracking
- [ ] Audit logs

---

## Next Steps

1. ✅ **Auto-unwrap responses** - DONE
2. ✅ **Normalize permissions** - DONE
3. ⏳ **Test admin creation** - IN PROGRESS
4. ⏳ **Update analytics paths**
5. ⏳ **Handle pagination variations**
6. ⏳ **Update service type IDs to String**

---

## Backend Contract Verification

Confirmed working endpoints:
- ✅ POST `/api/v1/admin/auth/request-otp`
- ✅ POST `/api/v1/admin/auth/login`
- ✅ GET `/api/v1/admin/auth/me`
- ✅ GET `/api/v1/admin/accounts`
- ✅ GET `/api/v1/admin/accounts/{id}`
- ✅ GET `/api/v1/admin/service-types`
- ✅ POST `/api/v1/admin/service-types`
- ✅ PATCH `/api/v1/admin/service-types/{id}`
- ✅ GET `/api/v1/admin/plans`
- ✅ POST `/api/v1/admin/plans`
- ✅ GET `/api/v1/admin/plans/{id}`
- ✅ PATCH `/api/v1/admin/plans/{id}`
- ✅ GET `/api/v1/admin/services`
- ✅ GET `/api/v1/admin/payments`
- ✅ GET `/api/v1/admin/invoices`
- ✅ GET `/api/v1/admin/subscriptions`
- ✅ GET `/api/v1/admin/campaigns/promo-ledger`
- ✅ GET `/api/v1/admin/referrals/vendor/{id}`
- ✅ GET `/api/v1/admin/audit`
- ✅ GET `/api/v1/admin/jobs`
- ✅ GET `/api/v1/admin/system/health`

Endpoints with issues:
- ❌ GET `/api/v1/admin/reviews` - INTERNAL_ERROR
- ❌ GET `/api/v1/admin/admin/analytics/dashboard-summary` - INTERNAL_ERROR
- ❌ POST `/api/v1/admin/roles/assign` - Validation error (needs different format)
