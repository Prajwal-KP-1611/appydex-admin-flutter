# API Validation Rules & Frontend Integration Guide

**Date**: November 12, 2025  
**Version**: v1 (Security Hardening Release)  
**Status**: Active  
**Impact**: Low — Existing implementations remain compatible; new validations enforce reasonable limits

---

## Overview

Recent security hardening has added input validation constraints to query parameters across admin and vendor endpoints. These changes enforce maximum lengths and allowed values to prevent abuse while maintaining full backward compatibility with existing frontend implementations.

**Key point**: If your current queries are reasonable (e.g., search terms under 64 chars, status values are actual enum values), **no changes are required**. These validations only reject malicious or malformed inputs.

---

## Admin Endpoints — Query Parameter Validation

### 1. Admin Bookings (`GET /api/v1/admin/bookings`)

**Added constraints**:
- `search`: min 2 chars, max 64 chars (only when provided)
- `status`: Must be one of: `"scheduled"`, `"paid"`, `"completed"`, `"canceled"` (only when provided)
- `sort_by`: Must be one of: `"created_at"`, `"start_at"`, `"status"`
- `sort_order`: Must be one of: `"asc"`, `"desc"`

**Example valid request**:
```bash
GET /api/v1/admin/bookings?search=john&status=paid&sort_by=created_at&sort_order=desc
```

**What will be rejected** (returns 422):
- `search` with 1 character or > 64 characters
- `status` with invalid value like `"completed123"` or gibberish
- `sort_by` with value like `"invalid_field"`

---

### 2. Admin Bookings Update (`PATCH /api/v1/admin/bookings/{id}`)

**Added constraints**:
- `status`: Must be one of: `"scheduled"`, `"paid"`, `"completed"`, `"canceled"` (only when provided)
- `admin_notes`: max 500 chars (only when provided)
- `cancellation_reason`: max 200 chars (only when provided)

**Current Frontend Implementation**: ✅ Already compliant
- Admin notes: 5-1000 chars client-side (backend allows 500)
- Cancellation reason: 10-500 chars client-side (backend allows 200)

**Action Required**: Adjust client-side limits to match backend:

```dart
// lib/features/bookings/screens/booking_detail_screen.dart
// Update validation methods:

String? _validateReason(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Reason is required';
  if (trimmed.length < 10) return 'Reason must be at least 10 characters';
  if (trimmed.length > 200) return 'Reason must not exceed 200 characters'; // ⚠️ Changed from 500
  return null;
}

String? _validateNotes(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Notes are required';
  if (trimmed.length < 5) return 'Notes must be at least 5 characters';
  if (trimmed.length > 500) return 'Notes must not exceed 500 characters'; // ⚠️ Changed from 1000
  return null;
}
```

---

### 3. Admin Referrals (`GET /api/v1/admin/referrals`)

**Added constraints**:
- `status`: Must be one of: `"pending"`, `"completed"`, `"cancelled"` (only when provided; validated at runtime with 400 error)
- `sort_by`: Must be one of: `"created_at"`, `"status"` (validated at runtime with 400 error)
- `sort_order`: Must be one of: `"asc"`, `"desc"` (validated at runtime with 400 error)

**Note**: Status/sort validation returns 400 with a descriptive error message if invalid values are sent.

**Current Frontend Implementation**: ✅ Already compliant
- Uses enum values from `ReferralStatus` model
- Sort values are hardcoded constants

---

### 4. Admin Payments (`GET /api/v1/admin/payments`)

**Added constraints**:
- `status`: max 50 chars (only when provided)
- `actor_type`: max 50 chars (only when provided)
- `provider_ref`: max 200 chars (only when provided)

**Impact**: Minimal — these are typically short strings like `"succeeded"`, `"booking"`, or reference IDs.

---

### 5. Admin Subscription Payments (`GET /api/v1/admin/subscriptions/payments`)

**Added constraints**:
- `status`: max 50 chars (only when provided)
- `sort_by`: max 50 chars
- `sort_order`: max 10 chars

**Impact**: Minimal — typical values like `"created_at"`, `"asc"`, `"desc"` are well within limits.

---

## Vendor Endpoints — Query Parameter Validation

### 1. Vendor Refunds (`GET /api/v1/vendor/refunds`)

**Added constraints**:
- `status`: max 50 chars (only when provided)

**Impact**: None for typical usage (e.g., `"pending"`, `"approved"`, `"processed"`).

---

## Error Responses

### 422 Unprocessable Entity
For query param length/type violations:
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation error",
    "details": [
      {
        "loc": ["query", "search"],
        "msg": "ensure this value has at least 2 characters",
        "type": "value_error.any_str.min_length"
      }
    ]
  }
}
```

### 400 Bad Request
For invalid enum values:
```json
{
  "success": false,
  "error": {
    "code": "INVALID_STATUS",
    "message": "Status must be one of: pending, completed, cancelled"
  }
}
```

---

## Frontend Implementation Guide

### ✅ No Action Required If:
- Search terms are reasonable length (< 64 chars)
- Status/sort values match documented enums
- Filter strings are under 200 chars

### ⚠️ Action Required:

#### 1. Update Dialog Validation Limits

**File**: `lib/features/bookings/screens/booking_detail_screen.dart`

Current limits don't match backend:
- Admin notes: Client allows 1000, backend allows 500
- Cancellation reason: Client allows 500, backend allows 200

**Fix**: See code changes above in Section 2.

#### 2. Add Search Length Validation

**File**: `lib/features/bookings/screens/bookings_list_screen.dart`

Add validation to search field:

```dart
void _onSearchChanged() {
  final search = _searchController.text;
  
  // Validate length
  if (search.isNotEmpty && search.length < 2) {
    // Show inline error or ignore (backend will reject)
    return;
  }
  if (search.length > 64) {
    // Truncate or show error
    _searchController.text = search.substring(0, 64);
    return;
  }
  
  ref.read(bookingsSearchProvider.notifier).updateSearchTerm(search);
}
```

**Recommended**: Add `maxLength: 64` to TextField:

```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search by booking number...',
    prefixIcon: const Icon(Icons.search),
    counterText: '', // Hide character counter
  ),
  maxLength: 64, // ⚠️ Add this
  // ... rest of properties
)
```

#### 3. Update Error Handling

**File**: `lib/core/error_mapper.dart`

Enhance 422 error handling to show validation details:

```dart
static String _mapBadResponse(DioException error) {
  final statusCode = error.response?.statusCode;
  final data = error.response?.data;

  // Try to extract error message from response
  String? serverMessage;
  if (data is Map<String, dynamic>) {
    serverMessage = data['message'] as String? ??
        data['error'] as String? ??
        data['detail'] as String?;
    
    // ⚠️ ADD: Handle validation error details
    if (statusCode == 422 && data['error'] is Map) {
      final errorData = data['error'] as Map<String, dynamic>;
      final details = errorData['details'] as List?;
      if (details != null && details.isNotEmpty) {
        final firstError = details.first as Map<String, dynamic>;
        final msg = firstError['msg'] as String?;
        final loc = firstError['loc'] as List?;
        if (msg != null) {
          final field = loc?.isNotEmpty == true ? loc![1] : 'field';
          return '$field: $msg';
        }
      }
    }
  }

  // ... rest of existing code
}
```

---

## Migration Checklist

### Immediate Actions (Required)
- [ ] Update cancellation reason max length: 500 → 200 chars
- [ ] Update admin notes max length: 1000 → 500 chars
- [ ] Update maxLength attributes in TextFields
- [ ] Test validation with edge cases (199 chars, 201 chars, etc.)

### Recommended Improvements
- [ ] Add search field length validation (min 2, max 64)
- [ ] Add maxLength to all search TextFields
- [ ] Enhance error mapper to show validation details from 422
- [ ] Add unit tests for validation methods
- [ ] Update user-facing error messages

### Nice to Have
- [ ] Show character count for admin notes/cancellation reason
- [ ] Debounce search to avoid API calls with < 2 chars
- [ ] Add inline validation hints before submission

---

## Testing Validation

### Test Cases for Booking Updates

```dart
// Test cancellation reason validation
test('should reject cancellation reason > 200 chars', () {
  final reason = 'a' * 201;
  final error = _validateReason(reason);
  expect(error, isNotNull);
  expect(error, contains('200 characters'));
});

test('should accept cancellation reason = 200 chars', () {
  final reason = 'a' * 200;
  final error = _validateReason(reason);
  expect(error, isNull);
});

// Test admin notes validation
test('should reject admin notes > 500 chars', () {
  final notes = 'a' * 501;
  final error = _validateNotes(notes);
  expect(error, isNotNull);
  expect(error, contains('500 characters'));
});

test('should accept admin notes = 500 chars', () {
  final notes = 'a' * 500;
  final error = _validateNotes(notes);
  expect(error, isNull);
});
```

### Manual Testing Checklist

- [ ] Search with 1 character (should not search or show error)
- [ ] Search with 2 characters (should work)
- [ ] Search with 64 characters (should work)
- [ ] Search with 65 characters (should truncate or error)
- [ ] Cancel booking with 200 char reason (should work)
- [ ] Cancel booking with 201 char reason (should error)
- [ ] Add notes with 500 chars (should work)
- [ ] Add notes with 501 chars (should error)
- [ ] Use invalid status in filters (should get 422/400)

---

## Security Context

These validations were added as part of production security hardening to:
- **Prevent buffer overflow attempts**
- **Block SQL injection via excessively long strings**
- **Enforce API contract compliance**
- **Improve error messages for invalid inputs**

All changes are **backward compatible** — valid requests continue to work unchanged.

---

## Current Compliance Status

### ✅ Compliant Areas
- Booking status filters (uses enum values)
- Referral status filters (uses enum values)
- Sort parameters (hardcoded constants)
- Search implementation (uses query params correctly)

### ⚠️ Requires Updates
- Cancellation reason max length: 500 → **200** (over limit)
- Admin notes max length: 1000 → **500** (over limit)
- Search field: No min length check (missing 2 char minimum)
- Search field: No max length limit (missing 64 char maximum)

### Priority
1. **HIGH**: Update admin notes & cancellation reason limits (prevents 422 errors)
2. **MEDIUM**: Add search length validation (better UX)
3. **LOW**: Enhance error messaging for validation failures

---

## Questions or Issues?

If you encounter any validation errors with legitimate use cases, please report them with:
1. The endpoint and parameters you're sending
2. The error response received
3. The intended use case

**Contact**: Backend team or file an issue in the repo.

---

## See Also

- [Pre-Production Readiness](../PRE_PRODUCTION_READINESS.md)
- [Security Best Practices](./SECURITY_BEST_PRACTICES.md)
- [Error Handling Guide](../guides/ERROR_HANDLING.md)
