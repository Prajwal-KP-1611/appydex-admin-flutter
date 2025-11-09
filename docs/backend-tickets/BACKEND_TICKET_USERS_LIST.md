# 🔴 CRITICAL: Missing Users List Endpoint

**Ticket ID:** `BACKEND-USERS-LIST-001`  
**Priority:** 🔴 **P0 - BLOCKING**  
**Created:** November 9, 2025  
**Status:** ⏳ **WAITING FOR BACKEND**  
**Impact:** Frontend cannot display users list page

---

## 🚨 ISSUE DESCRIPTION

The users list screen at `/users` is returning **404 Not Found**. The backend has NOT implemented the paginated users list endpoint.

### What's Missing:

**Endpoint:** `GET /api/v1/admin/users`

This endpoint was **NOT included** in the End-User Management APIs response (BACKEND-EU-001). The backend only implemented:
- ✅ `GET /api/v1/admin/users/{user_id}` - User detail
- ❌ `GET /api/v1/admin/users` - Users list (MISSING!)

---

## 📋 REQUIRED ENDPOINT

### Endpoint Specification

```
GET /api/v1/admin/users
```

**Query Parameters:**
```
?page=1
&limit=20
&search=john          # Search by name/email/phone
&status=active        # Filter: active|suspended|banned
&verification=2       # Filter by verification level (0-3)
&trust_score_min=50   # Filter by minimum trust score
&trust_score_max=100  # Filter by maximum trust score
&sort_by=created_at   # Sort by: created_at|name|trust_score|last_active_at
&sort_order=desc      # asc|desc
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "email": "customer@example.com",
        "phone": "+919876543210",
        "name": "John Doe",
        "is_active": true,
        "is_suspended": false,
        "account_status": "active",
        "trust_score": 85,
        "created_at": "2025-01-15T10:30:00Z",
        "last_active_at": "2025-11-09T14:20:00Z",
        
        "verification_level": 2,
        "email_verified": true,
        "phone_verified": true,
        "identity_verified": false,
        
        "total_bookings": 15,
        "total_spent": 250000,
        "total_disputes": 2
      }
    ],
    "meta": {
      "total": 79,
      "page": 1,
      "page_size": 20,
      "total_pages": 4
    }
  }
}
```

**Status Codes:**
- `200` - Success
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `500` - Server error

---

## 🔍 CURRENT BEHAVIOR

**Frontend Request:**
```
GET http://localhost:16110/api/v1/admin/users?page=1&limit=20
Authorization: Bearer <admin_token>
```

**Backend Response:**
```
HTTP/1.1 404 Not Found
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Endpoint not found"
  }
}
```

---

## ✅ EXPECTED BEHAVIOR

**Backend Response:**
```
HTTP/1.1 200 OK
{
  "success": true,
  "data": {
    "items": [...79 users...],
    "meta": {
      "total": 79,
      "page": 1,
      "page_size": 20,
      "total_pages": 4
    }
  }
}
```

---

## 🎯 BUSINESS IMPACT

### Without this endpoint, frontend CANNOT:
- ❌ Display users list page
- ❌ Search for users by name/email
- ❌ Filter users by status/verification
- ❌ Sort users by trust score
- ❌ Navigate to user details from list
- ❌ Perform bulk actions on users
- ❌ Export users data

### Current Workaround:
Frontend is using **mock data** (79 dummy users) to unblock development, but this:
- ⚠️ Shows fake data to admins
- ⚠️ Cannot test real user scenarios
- ⚠️ Blocks QA testing
- ⚠️ Blocks production deployment

---

## 🛠️ IMPLEMENTATION CHECKLIST

### Backend Tasks:

1. **Create Endpoint**
   - [ ] Route: `GET /api/v1/admin/users`
   - [ ] Controller: `AdminUsersController.list()`
   - [ ] Query builder with filters

2. **Implement Filters**
   - [ ] Search (name, email, phone)
   - [ ] Status filter (active/suspended/banned)
   - [ ] Verification level filter
   - [ ] Trust score range filter

3. **Implement Sorting**
   - [ ] Sort by: created_at, name, trust_score, last_active_at
   - [ ] Sort order: asc/desc

4. **Implement Pagination**
   - [ ] Page number (default: 1)
   - [ ] Page size (default: 20, max: 100)
   - [ ] Total count
   - [ ] Total pages

5. **Optimize Performance**
   - [ ] Add database indexes (email, phone, trust_score, created_at)
   - [ ] Use database pagination (LIMIT/OFFSET)
   - [ ] Select only required fields
   - [ ] Cache results (1 minute)

6. **Add RBAC**
   - [ ] Require `users.view` permission
   - [ ] Enforce admin role
   - [ ] Audit log: "Admin viewed users list"

7. **Testing**
   - [ ] Unit tests for filters
   - [ ] Unit tests for sorting
   - [ ] Integration test with real database
   - [ ] Performance test (>1000 users)

---

## 📝 SQL QUERY EXAMPLE

```sql
SELECT 
    u.id,
    u.email,
    u.phone,
    u.name,
    u.is_active,
    u.is_suspended,
    u.trust_score,
    u.created_at,
    u.last_active_at,
    u.email_verified_at IS NOT NULL AS email_verified,
    u.phone_verified_at IS NOT NULL AS phone_verified,
    u.identity_verified,
    COUNT(DISTINCT b.id) AS total_bookings,
    COALESCE(SUM(pi.amount), 0) AS total_spent,
    COUNT(DISTINCT d.id) AS total_disputes,
    CASE 
        WHEN u.email_verified_at IS NOT NULL 
             AND u.phone_verified_at IS NOT NULL 
             AND u.identity_verified THEN 3
        WHEN u.email_verified_at IS NOT NULL 
             AND u.phone_verified_at IS NOT NULL THEN 2
        WHEN u.email_verified_at IS NOT NULL 
             OR u.phone_verified_at IS NOT NULL THEN 1
        ELSE 0
    END AS verification_level
FROM users u
LEFT JOIN bookings b ON u.id = b.user_id
LEFT JOIN payment_intents pi ON b.id = pi.booking_id AND pi.status = 'succeeded'
LEFT JOIN disputes d ON u.id = d.user_id
WHERE 1=1
    AND (:search IS NULL OR u.name ILIKE :search OR u.email ILIKE :search)
    AND (:status IS NULL OR u.account_status = :status)
    AND (:trust_score_min IS NULL OR u.trust_score >= :trust_score_min)
    AND (:trust_score_max IS NULL OR u.trust_score <= :trust_score_max)
GROUP BY u.id
ORDER BY 
    CASE WHEN :sort_by = 'created_at' AND :sort_order = 'desc' THEN u.created_at END DESC,
    CASE WHEN :sort_by = 'created_at' AND :sort_order = 'asc' THEN u.created_at END ASC,
    CASE WHEN :sort_by = 'name' AND :sort_order = 'desc' THEN u.name END DESC,
    CASE WHEN :sort_by = 'name' AND :sort_order = 'asc' THEN u.name END ASC,
    CASE WHEN :sort_by = 'trust_score' AND :sort_order = 'desc' THEN u.trust_score END DESC,
    CASE WHEN :sort_by = 'trust_score' AND :sort_order = 'asc' THEN u.trust_score END ASC
LIMIT :limit OFFSET :offset;
```

---

## 🎯 ACCEPTANCE CRITERIA

### Must Have:
- [x] Endpoint returns 200 with valid admin token
- [ ] Returns paginated list of users (default 20 per page)
- [ ] Search by name/email/phone works
- [ ] Status filter works (active/suspended/banned)
- [ ] Trust score range filter works
- [ ] Sorting by created_at, name, trust_score works
- [ ] Response includes meta with total count
- [ ] Response includes basic user fields + verification + activity summary
- [ ] Performance: < 500ms for 79 users

### Nice to Have:
- [ ] Verification level filter (0-3)
- [ ] Cache responses for 1 minute
- [ ] Export to CSV support
- [ ] Bulk selection support

---

## 🚀 PRIORITY JUSTIFICATION

This is **P0 CRITICAL** because:

1. **Blocking Feature:** Users management is a core admin feature
2. **Cannot Test:** QA cannot test real user scenarios
3. **Production Blocker:** Cannot deploy without this endpoint
4. **User Experience:** Admins need to view all users, not just user detail
5. **Integration Gap:** Backend delivered 18 endpoints but missed the most important one

---

## 📞 FRONTEND STATUS

**Current State:**
- ✅ UI complete and ready
- ✅ Mock data fallback implemented (79 fake users)
- ✅ Filters and sorting work with mock data
- ✅ Pagination works with mock data
- ❌ Cannot test with real backend
- ❌ Cannot deploy to production

**Waiting for backend to:**
1. Implement `GET /api/v1/admin/users` endpoint
2. Deploy to port 16110
3. Notify frontend team
4. Frontend will remove mock data fallback

---

## 📋 RELATED TICKETS

- ✅ `BACKEND-EU-001` - End-User Management APIs (18 endpoints) - COMPLETE
- ⏳ `BACKEND-USERS-LIST-001` - Users List Endpoint (THIS TICKET) - WAITING

---

## 🎉 WHEN COMPLETE

Frontend will:
1. Remove mock data fallback
2. Test with real 79 users
3. Verify filters and sorting
4. Complete QA testing
5. Mark users management as production-ready

---

**Ticket Created By:** Frontend Team  
**Assigned To:** Backend API Team  
**Expected Delivery:** ASAP (P0)  
**Status:** ⏳ WAITING FOR BACKEND

---

**Note to Backend Team:**

This endpoint was missed in the original End-User Management APIs delivery (BACKEND-EU-001). The ticket requested "comprehensive end-user management" but did not explicitly list a "users list" endpoint. 

However, **it's impossible to have user management without a list endpoint!** 

Please prioritize this as P0 and deliver ASAP. Frontend is blocked on this for production deployment.

Thank you! 🙏
