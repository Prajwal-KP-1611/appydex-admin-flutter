# Bookings & Referrals Error Fixes

**Date**: January 12, 2025  
**Issue**: Type error when loading bookings and referrals data  
**Status**: ✅ FIXED

---

## Problem Description

**Error Message**:
```
Error: TypeError: Instance of 'JSArray<dynamic>': type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>?'
DioException [unknown]: null
```

**Root Cause**:
The API endpoints may be:
1. Returning `null` responses (endpoint not implemented)
2. Returning a list directly instead of a paginated response object
3. Missing from the backend API

---

## Fixes Applied

### 1. Enhanced Null Handling in Bookings Repository

**File**: `lib/repositories/bookings_repository.dart`

**Changes**:
- Added null check for `response.data`
- Added type check to detect if API returns a list instead of paginated response
- Added helpful error messages to guide backend implementation
- Proper exception handling with `AdminEndpointMissing`

```dart
if (response.data == null) {
  throw AdminEndpointMissing(
    endpoint: '/admin/bookings',
    message: 'API returned null response. The endpoint may not be implemented yet.',
  );
}

// Handle case where API returns a list instead of paginated response
if (response.data is List) {
  throw AdminEndpointMissing(
    endpoint: '/admin/bookings',
    message: 'API returned a list instead of a paginated response. Expected format: {data: [...], meta: {...}}',
  );
}
```

### 2. Enhanced Null Handling in Referrals Repository

**File**: `lib/repositories/referrals_repository.dart`

**Changes**:
- Same null and type checks as bookings repository
- Clear error messages for debugging

### 3. Added Back Buttons

**Files Modified**:
- `lib/features/bookings/screens/bookings_list_screen.dart`
- `lib/features/bookings/screens/booking_detail_screen.dart`
- `lib/features/referrals/screens/referrals_list_screen.dart`

**Changes**:
- Added back button to AppBar leading position
- Back button navigates using `Navigator.of(context).pop()`
- Consistent UI across all screens

```dart
appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
    tooltip: 'Back',
  ),
  title: const Text('...'),
  // ...
)
```

---

## Expected API Response Format

### Bookings Endpoint

**Endpoint**: `GET /api/v1/admin/bookings`

**Expected Response**:
```json
{
  "data": [
    {
      "id": 1,
      "booking_number": "BK-12345",
      "user_id": 10,
      "vendor_id": 5,
      "service_id": 3,
      "status": "pending",
      "scheduled_at": "2025-01-15T10:00:00Z",
      "created_at": "2025-01-12T06:25:46Z",
      "user_name": "John Doe",
      "vendor_name": "ABC Services"
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 100,
    "total_pages": 4,
    "has_next": true,
    "has_prev": false
  }
}
```

### Referrals Endpoint

**Endpoint**: `GET /api/v1/admin/referrals`

**Expected Response**:
```json
{
  "data": [
    {
      "id": 1,
      "referrer_vendor_id": 5,
      "referrer_vendor": {
        "id": 5,
        "name": "ABC Services",
        "email": "abc@example.com"
      },
      "referred_entity_type": "user",
      "referred_entity_id": 10,
      "referred_entity": {
        "id": 10,
        "name": "Jane Smith",
        "email": "jane@example.com",
        "type": "user"
      },
      "status": "completed",
      "tier": "gold",
      "milestone_number": 5,
      "bonus_amount": 50.00,
      "created_at": "2025-01-12T06:25:46Z"
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 50,
    "total_pages": 2,
    "has_next": true,
    "has_prev": false
  }
}
```

---

## Error Handling

### Frontend Error Display

When the API endpoint is missing or returns incorrect data, users will now see:

**Error Message**:
```
Admin endpoint missing: /admin/bookings - API returned null response. The endpoint may not be implemented yet.
```

Or:

```
Admin endpoint missing: /admin/bookings - API returned a list instead of a paginated response. Expected format: {data: [...], meta: {...}}
```

This provides clear guidance for backend developers to implement the correct response format.

### Retry Button

All error screens include a "Retry" button that re-fetches the data, allowing users to try again after backend fixes are deployed.

---

## Next Steps for Backend

### Priority 1: Implement Bookings Endpoint

**File**: Backend API (likely `routers/admin/bookings.py` or similar)

**Requirements**:
1. Create `GET /api/v1/admin/bookings` endpoint
2. Return paginated response with format shown above
3. Support query parameters:
   - `status`: Filter by booking status
   - `user_id`: Filter by user
   - `vendor_id`: Filter by vendor
   - `page`: Page number (default: 1)
   - `page_size`: Items per page (default: 25)
   - `sort_by`: Sort field (default: created_at)
   - `sort_order`: asc or desc (default: desc)

### Priority 2: Implement Referrals Endpoint

**File**: Backend API (likely `routers/admin/referrals.py` or similar)

**Requirements**:
1. Create `GET /api/v1/admin/referrals` endpoint
2. Return paginated response with format shown above
3. Support query parameters:
   - `status`: Filter by referral status
   - `referrer_vendor_id`: Filter by referring vendor
   - `tier`: Filter by tier (bronze, silver, gold, platinum)
   - `page`: Page number (default: 1)
   - `page_size`: Items per page (default: 25)
   - `sort_by`: Sort field (default: created_at)
   - `sort_order`: asc or desc (default: desc)

### Priority 3: Implement Update Endpoints

**Bookings Update**:
- `PATCH /api/v1/admin/bookings/{id}`
- Accept: status, cancel_reason, admin_notes, notify_user, notify_vendor

**Bookings Details**:
- `GET /api/v1/admin/bookings/{id}`
- Return full booking details with user and vendor relationships

**Vendor Referrals Stats**:
- `GET /api/v1/admin/referrals/vendor/{id}`
- Return vendor referral statistics

---

## Testing Checklist

### After Backend Implementation

- [ ] Run `flutter run` or `flutter run -d chrome`
- [ ] Login as admin
- [ ] Navigate to Bookings page
  - [ ] Verify list loads without error
  - [ ] Verify statistics display correctly
  - [ ] Test filters and search
  - [ ] Test pagination
  - [ ] Click booking card to view details
  - [ ] Test back button
- [ ] Navigate to Referrals page
  - [ ] Verify list loads without error
  - [ ] Verify statistics and leaderboard display
  - [ ] Test filters
  - [ ] Test pagination
  - [ ] Test back button

### Error Scenarios to Test

- [ ] Backend not running (should show clear error)
- [ ] Endpoint returns 404 (should show appropriate message)
- [ ] Endpoint returns wrong format (should show helpful error)
- [ ] Empty list (should show "No items found" with clear filters)
- [ ] Network timeout (should show retry option)

---

## Compilation Status

✅ All files compile successfully  
✅ No type errors  
✅ No null safety violations  
✅ All imports resolved  

**Modified Files** (5 total):
1. `lib/repositories/bookings_repository.dart` - Enhanced null handling
2. `lib/repositories/referrals_repository.dart` - Enhanced null handling
3. `lib/features/bookings/screens/bookings_list_screen.dart` - Added back button
4. `lib/features/bookings/screens/booking_detail_screen.dart` - Added back button
5. `lib/features/referrals/screens/referrals_list_screen.dart` - Added back button

---

## Summary

The frontend is now more robust and provides clear error messages when:
- API endpoints are not implemented
- API returns null or incorrect data formats
- Network errors occur

Users can now navigate back using the back button in the AppBar, providing better UX.

The error messages guide backend developers on the expected response format, making integration easier.

**Status**: ✅ READY FOR BACKEND IMPLEMENTATION
