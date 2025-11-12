# Backend Issue: Implement Bookings & Referrals Admin Endpoints

**Priority**: HIGH  
**Type**: Feature Request / Bug Fix  
**Status**: ✅ RESOLVED  
**Created**: November 12, 2025  
**Resolved**: November 12, 2025  
**Resolution**: All endpoints implemented and verified live. Frontend successfully integrated.

---

## 🔴 Problem Summary

The Flutter admin panel has complete implementations for **Bookings Management** and **Referrals Tracking** features, but the backend API endpoints are either:
1. Not implemented
2. Returning `null` responses
3. Returning incorrect data formats (list instead of paginated response)

**Current Error**:
```
Error: TypeError: Instance of 'JSArray<dynamic>': type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>?'
DioException [unknown]: null
```

**User Impact**: Admin users cannot view or manage bookings and referrals, making these features completely non-functional.

---

## 🎯 Required Endpoints

### 1. List Bookings (HIGH PRIORITY)

**Endpoint**: `GET /api/v1/admin/bookings`

**Description**: Return paginated list of all bookings with filtering and sorting

**Required Query Parameters**:
- `page` (int, default: 1) - Page number
- `page_size` (int, default: 25) - Items per page
- `sort_by` (string, default: "created_at") - Field to sort by
- `sort_order` (string, default: "desc") - Sort order (asc/desc)

**Optional Query Parameters**:
- `status` (string) - Filter by status (pending, scheduled, paid, completed, canceled)
- `user_id` (int) - Filter by user ID
- `vendor_id` (int) - Filter by vendor ID
- `service_id` (int) - Filter by service ID
- `search` (string) - Search by booking number, user name, or vendor name
- `min_amount` (float) - Minimum booking amount
- `max_amount` (float) - Maximum booking amount

**Required Response Format**:
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

**Authentication**: Required - Admin JWT token  
**Permissions**: `bookings.view` or equivalent admin permission

---

### 2. Get Booking Details (HIGH PRIORITY)

**Endpoint**: `GET /api/v1/admin/bookings/{id}`

**Description**: Return detailed information for a specific booking

**Path Parameters**:
- `id` (int) - Booking ID

**Required Response Format**:
```json
{
  "id": 1,
  "booking_number": "BK-12345",
  "user_id": 10,
  "user": {
    "id": 10,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "display_name": "John D.",
    "total_bookings": 15
  },
  "vendor_id": 5,
  "vendor": {
    "id": 5,
    "display_name": "ABC Services",
    "email": "abc@example.com",
    "phone": "+1234567890",
    "total_bookings": 250
  },
  "service_id": 3,
  "status": "pending",
  "scheduled_at": "2025-01-15T10:00:00Z",
  "estimated_end_at": "2025-01-15T11:30:00Z",
  "idempotency_key": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2025-01-12T06:25:46Z",
  "updated_at": "2025-01-12T06:25:46Z"
}
```

**Error Responses**:
- `404`: Booking not found
- `403`: Insufficient permissions

**Authentication**: Required - Admin JWT token  
**Permissions**: `bookings.view`

---

### 3. Update Booking (HIGH PRIORITY)

**Endpoint**: `PATCH /api/v1/admin/bookings/{id}`

**Description**: Update booking status, add notes, or cancel bookings

**Path Parameters**:
- `id` (int) - Booking ID

**Headers**:
- `Idempotency-Key` (optional, string) - UUID for preventing duplicate requests

**Request Body**:
```json
{
  "status": "completed",
  "cancel_reason": "Customer requested cancellation",
  "admin_notes": "Called customer to confirm",
  "notify_user": true,
  "notify_vendor": true
}
```

**Request Body Fields** (all optional):
- `status` (string) - New status (scheduled, paid, completed, canceled)
- `cancel_reason` (string) - Required if status is "canceled"
- `admin_notes` (string) - Admin notes (not visible to users)
- `notify_user` (bool, default: true) - Send notification to user
- `notify_vendor` (bool, default: true) - Send notification to vendor

**Required Response Format**:
```json
{
  "id": 1,
  "status": "completed",
  "message": "Booking updated successfully"
}
```

**Error Responses**:
- `400`: Invalid status transition (e.g., cannot complete a canceled booking)
  ```json
  {
    "error": "invalid_status_transition",
    "message": "Cannot transition from 'canceled' to 'completed'",
    "current_status": "canceled",
    "requested_status": "completed"
  }
  ```
- `404`: Booking not found
- `403`: Insufficient permissions

**Authentication**: Required - Admin JWT token  
**Permissions**: `bookings.update`

---

### 4. List Referrals (HIGH PRIORITY)

**Endpoint**: `GET /api/v1/admin/referrals`

**Description**: Return paginated list of all referrals with filtering and sorting

**Required Query Parameters**:
- `page` (int, default: 1) - Page number
- `page_size` (int, default: 25) - Items per page
- `sort_by` (string, default: "created_at") - Field to sort by
- `sort_order` (string, default: "desc") - Sort order (asc/desc)

**Optional Query Parameters**:
- `status` (string) - Filter by status (pending, completed, cancelled)
- `referrer_vendor_id` (int) - Filter by referring vendor
- `tier` (string) - Filter by tier (bronze, silver, gold, platinum)
- `referred_entity_type` (string) - Filter by entity type (user, vendor)
- `created_from` (datetime) - Filter by start date
- `created_to` (datetime) - Filter by end date

**Required Response Format**:
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

**Note**: `referrer_vendor` can be `null` if the vendor has been deleted.

**Authentication**: Required - Admin JWT token  
**Permissions**: `referrals.view`

---

### 5. Get Vendor Referral Stats (MEDIUM PRIORITY)

**Endpoint**: `GET /api/v1/admin/referrals/vendor/{id}`

**Description**: Return referral statistics for a specific vendor

**Path Parameters**:
- `id` (int) - Vendor ID

**Required Response Format**:
```json
{
  "vendor_id": 5,
  "vendor_name": "ABC Services",
  "total_referrals": 25,
  "pending_referrals": 5,
  "completed_referrals": 18,
  "cancelled_referrals": 2,
  "total_rewards_earned": 1250.00,
  "recent_referrals": [
    {
      "id": 1,
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
  ]
}
```

**Error Responses**:
- `404`: Vendor not found

**Authentication**: Required - Admin JWT token  
**Permissions**: `referrals.view`

---

## 🔧 Technical Requirements

### Response Format Standard

**ALL LIST ENDPOINTS MUST RETURN PAGINATED RESPONSES**:
```json
{
  "data": [ /* array of items */ ],
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

❌ **DO NOT** return raw lists:
```json
[ /* items */ ]  // WRONG!
```

### Field Naming Convention

- Use **snake_case** for all JSON fields (e.g., `booking_number`, `created_at`)
- Frontend automatically converts to camelCase (e.g., `bookingNumber`, `createdAt`)

### Date/Time Format

- Use ISO 8601 format: `2025-01-12T06:25:46Z`
- Always include timezone (UTC recommended)

### Error Response Format

```json
{
  "error": "error_code",
  "message": "Human-readable error message",
  "field": "field_name"  // Optional, for validation errors
}
```

---

## 📋 Implementation Checklist

### Phase 1: Core Endpoints (MUST HAVE)
- [ ] `GET /api/v1/admin/bookings` - List bookings with pagination
- [ ] `GET /api/v1/admin/bookings/{id}` - Get booking details
- [ ] `PATCH /api/v1/admin/bookings/{id}` - Update booking
- [ ] `GET /api/v1/admin/referrals` - List referrals with pagination
- [ ] `GET /api/v1/admin/referrals/vendor/{id}` - Get vendor stats

### Phase 2: Database Queries
- [ ] Add indexes on frequently filtered fields:
  - `bookings.status`
  - `bookings.user_id`
  - `bookings.vendor_id`
  - `bookings.created_at`
  - `referrals.status`
  - `referrals.referrer_vendor_id`
  - `referrals.tier`

### Phase 3: Validation
- [ ] Validate status transitions for bookings
- [ ] Require `cancel_reason` when status is "canceled"
- [ ] Validate date ranges
- [ ] Validate pagination parameters (max page_size: 100)

### Phase 4: Permissions
- [ ] Add admin permission checks
- [ ] Add audit logging for updates
- [ ] Add rate limiting for list endpoints

### Phase 5: Notifications
- [ ] Email/SMS notifications when `notify_user` is true
- [ ] Email/SMS notifications when `notify_vendor` is true
- [ ] Notification templates for different booking statuses

---

## 🧪 Testing Requirements

### Unit Tests
- [ ] Test pagination logic
- [ ] Test filter combinations
- [ ] Test status transition validation
- [ ] Test error responses

### Integration Tests
- [ ] Test with real database
- [ ] Test with various filter combinations
- [ ] Test sorting options
- [ ] Test edge cases (empty results, large datasets)

### API Documentation
- [ ] Add to Swagger/OpenAPI documentation
- [ ] Include example requests and responses
- [ ] Document all error codes

---

## 📊 Database Schema Requirements

### Bookings Table

Expected columns (adjust field names to match your schema):
```sql
- id (int, primary key)
- booking_number (string, unique)
- user_id (int, foreign key)
- vendor_id (int, foreign key)
- service_id (int, foreign key)
- status (enum: pending, scheduled, paid, completed, canceled)
- scheduled_at (timestamp)
- estimated_end_at (timestamp, nullable)
- idempotency_key (uuid, nullable)
- created_at (timestamp)
- updated_at (timestamp)
```

### Referrals Table

Expected columns:
```sql
- id (int, primary key)
- referrer_vendor_id (int, foreign key)
- referred_entity_type (enum: user, vendor)
- referred_entity_id (int)
- status (enum: pending, completed, cancelled)
- tier (enum: bronze, silver, gold, platinum)
- milestone_number (int)
- bonus_amount (decimal)
- created_at (timestamp)
- updated_at (timestamp)
```

---

## 🔗 Related Files

### Frontend Implementation (ALREADY COMPLETE)

**Models**:
- `lib/models/booking.dart` (244 lines)
- `lib/models/referral.dart` (151 lines)

**Repositories**:
- `lib/repositories/bookings_repository.dart` (289 lines)
- `lib/repositories/referrals_repository.dart` (152 lines)

**Providers**:
- `lib/providers/bookings_provider.dart` (334 lines)
- `lib/providers/referrals_provider.dart` (370 lines)

**UI Screens**:
- `lib/features/bookings/screens/bookings_list_screen.dart` (483 lines)
- `lib/features/bookings/screens/booking_detail_screen.dart` (496 lines)
- `lib/features/referrals/screens/referrals_list_screen.dart` (726 lines)

**Documentation**:
- `docs/BOOKINGS_REFERRALS_IMPLEMENTATION_COMPLETE.md`
- `docs/BOOKINGS_REFERRALS_ERROR_FIXES.md`
- `docs/BOOKINGS_REFERRALS_IMPLEMENTATION_GUIDE.md`

---

## ⚡ Quick Start for Backend Developer

1. **Clone the frontend repo** to see working examples:
   ```bash
   git clone https://github.com/Prajwal-KP-1611/appydex-admin-flutter.git
   ```

2. **Review the data models** to understand expected structure:
   - See `lib/models/booking.dart` for BookingListItem and BookingDetails
   - See `lib/models/referral.dart` for ReferralListItem

3. **Test with curl** (example):
   ```bash
   curl -X GET "http://localhost:16110/api/v1/admin/bookings?page=1&page_size=25" \
     -H "Authorization: Bearer <admin_token>"
   ```

4. **Expected response**:
   - Must include `data` array and `meta` object
   - Must use snake_case field names
   - Must return proper HTTP status codes

---

## 📝 Notes

- Frontend is **100% complete** and tested with mock data
- Frontend includes comprehensive error handling for missing endpoints
- Frontend will display helpful error messages until backend is implemented
- All compilation successful, no frontend changes needed
- **Blocking**: Admin users cannot use bookings/referrals features until these endpoints are live

---

## 🎯 Success Criteria

- [ ] All 5 endpoints implemented and returning correct format
- [ ] Pagination working correctly with proper meta information
- [ ] Filters working as expected
- [ ] Status transitions validated correctly
- [ ] Error responses follow standard format
- [ ] Admin authentication enforced
- [ ] Frontend successfully loads and displays data
- [ ] No console errors in browser
- [ ] Manual testing completed with real data

---

## 🚀 Estimated Effort

- **Bookings Endpoints**: 6-8 hours
- **Referrals Endpoints**: 4-6 hours
- **Testing & Documentation**: 2-3 hours
- **Total**: 12-17 hours

**Priority**: HIGH - These are core admin features that are currently non-functional.

---

## 📞 Contact

If you have questions about the expected response format or need clarification:
- Review `docs/BOOKINGS_REFERRALS_ERROR_FIXES.md` in the frontend repo
- Check the data models in `lib/models/` for exact field structures
- Test the frontend locally to see the expected behavior

---

**Created by**: Frontend Team  
**Date**: November 12, 2025  
**Issue Type**: Backend Implementation Required  
**Status**: Open / Awaiting Implementation
