# Backend Quick Reference: Bookings & Referrals API

**URGENT**: 5 endpoints needed for admin panel functionality

---

## 🎯 Required Endpoints (Summary)

| # | Endpoint | Method | Priority | Status |
|---|----------|--------|----------|--------|
| 1 | `/api/v1/admin/bookings` | GET | HIGH | ❌ Missing |
| 2 | `/api/v1/admin/bookings/{id}` | GET | HIGH | ❌ Missing |
| 3 | `/api/v1/admin/bookings/{id}` | PATCH | HIGH | ❌ Missing |
| 4 | `/api/v1/admin/referrals` | GET | HIGH | ❌ Missing |
| 5 | `/api/v1/admin/referrals/vendor/{id}` | GET | MEDIUM | ❌ Missing |

---

## ⚠️ CRITICAL: Response Format

### ✅ CORRECT (Paginated Response)
```json
{
  "data": [ /* items */ ],
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

### ❌ WRONG (Raw List)
```json
[ /* items */ ]  // DO NOT DO THIS!
```

---

## 🔑 Key Requirements

1. **Use snake_case** for all JSON fields
2. **Always paginate** list endpoints
3. **ISO 8601 dates**: `2025-01-12T06:25:46Z`
4. **Admin auth required**: JWT Bearer token
5. **Proper error codes**: 400 (validation), 403 (permission), 404 (not found)

---

## 📦 Example Response: Bookings List

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

---

## 📦 Example Response: Referrals List

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

## 🧪 Quick Test

```bash
# Test bookings endpoint
curl -X GET "http://localhost:16110/api/v1/admin/bookings?page=1&page_size=25" \
  -H "Authorization: Bearer <admin_token>"

# Test referrals endpoint
curl -X GET "http://localhost:16110/api/v1/admin/referrals?page=1&page_size=25" \
  -H "Authorization: Bearer <admin_token>"
```

---

## 📖 Full Documentation

See: `docs/backend-tickets/BACKEND_ISSUE_bookings_referrals_endpoints.md`

**Estimated Effort**: 12-17 hours  
**Impact**: HIGH - Admin panel features are non-functional without these endpoints
