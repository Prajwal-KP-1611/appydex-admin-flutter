# ⚡ Quick Reference: Reviews Takedown Implementation

**For Backend Team - Start Here** 👋

---

## 📦 What You Got

1. **Complete FastAPI Router** (900+ lines)
   - File: `IMPLEMENTATION_reviews_takedown.py`
   - All 3 endpoints coded
   - Just uncomment TODOs

2. **Database Migration SQL**
   - At bottom of router file
   - Copy-paste ready

3. **Implementation Guide** (30 pages)
   - File: `IMPLEMENTATION_GUIDE_reviews_takedown.md`
   - Step-by-step instructions
   - 10 test scenarios

---

## ⚡ 5-Minute Quick Start

### 1. Copy File (30 seconds)
```bash
cp docs/backend-tickets/IMPLEMENTATION_reviews_takedown.py \
   backend/app/routers/admin/reviews_takedown.py
```

### 2. Run Migration (2 minutes)
```bash
# Copy SQL from bottom of IMPLEMENTATION_reviews_takedown.py
psql -U postgres -d appydex -f migration.sql
```

### 3. Register Router (1 minute)
```python
# In backend/app/main.py (around line 30)
from app.routers.admin import reviews_takedown

# Around line 150
app.include_router(
    reviews_takedown.router, 
    prefix="/api/v1/admin", 
    tags=["Admin Reviews Takedown"]
)
```

### 4. Update Imports (1 minute)
```python
# At top of reviews_takedown.py - uncomment these:
from app.database import get_db
from app.models import ReviewTakedownRequest, Review, Vendor, AdminUser
from app.auth import get_current_admin_user, check_permission
from app.services.notifications import NotificationService
from app.cache import cache_with_ttl
```

### 5. Test (30 seconds)
```bash
# Start server
uvicorn app.main:app --reload --port 16110

# Test
curl http://localhost:16110/api/v1/admin/reviews/takedown-requests \
  -H "Authorization: Bearer YOUR_TOKEN"

# Expected: {"success": true, "data": [], "meta": {...}}
```

---

## 📝 What TODOs to Uncomment

### In `list_takedown_requests()` function (line ~230)
```python
# Uncomment these lines:
query = select(ReviewTakedownRequest).options(...)
filters = []
if status:
    filters.append(ReviewTakedownRequest.status == status)
# ... rest of filter logic
# ... sorting logic
# ... pagination logic
results = db.execute(query).scalars().all()
```

### In `get_takedown_request()` function (line ~340)
```python
# Uncomment:
query = select(ReviewTakedownRequest).options(...).where(...)
result = db.execute(query).scalar_one_or_none()
if not result:
    raise HTTPException(status_code=404, ...)
```

### In `resolve_takedown_request()` function (line ~450)
```python
# Uncomment entire transaction block:
# - Idempotency check
# - Get request with locking
# - Check if already resolved
# - Update request status
# - Update review status
# - Create audit log
# - Commit transaction
# - Queue notifications
```

---

## 🧪 Quick Test

### Get Admin Token
```bash
TOKEN=$(curl -s -X POST "http://localhost:16110/api/v1/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@appydex.local","password":"admin123!@#"}' \
  | jq -r '.data.access_token')
```

### Test List Endpoint
```bash
curl "http://localhost:16110/api/v1/admin/reviews/takedown-requests" \
  -H "Authorization: Bearer $TOKEN"
```

### Expected Response
```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "page_size": 25,
    "total_items": 0,
    "total_pages": 0,
    "has_next": false,
    "has_prev": false,
    "summary": {
      "open": 0,
      "accepted": 0,
      "rejected": 0
    }
  }
}
```

---

## 🐛 Common Issues

### Issue: Import Error
```
ImportError: cannot import name 'ReviewTakedownRequest'
```
**Fix:** Create SQLAlchemy model (see IMPLEMENTATION_GUIDE line 450)

### Issue: 404 Not Found
```
404 for /api/v1/admin/reviews/takedown-requests
```
**Fix:** Check router is registered in main.py

### Issue: Permission Denied
```
{"error": {"code": "PERMISSION_DENIED"}}
```
**Fix:** Grant permission to admin
```sql
INSERT INTO role_permissions (role_id, permission)
VALUES ((SELECT id FROM roles WHERE name = 'admin'), 'reviews:moderate');
```

---

## 📚 Full Documentation

- **Detailed Guide:** `IMPLEMENTATION_GUIDE_reviews_takedown.md` (30 pages)
- **Original Ticket:** `BACKEND_TICKET_REVIEWS_TAKEDOWN_SYSTEM.md`
- **Delivery Summary:** `IMPLEMENTATION_DELIVERY_SUMMARY_reviews_takedown.md`

---

## ⏱️ Time Estimate

- **Day 1:** Copy file, run migration, register router, uncomment TODOs (4-5 hours)
- **Day 2:** Implement notifications, test (4-5 hours)
- **Day 3:** Write tests, performance testing (6-8 hours)
- **Day 4:** Code review, deploy (2-3 hours)

**Total:** 3-4 days

---

## ✅ Checklist

- [ ] Copy router file to backend
- [ ] Run database migration
- [ ] Register router in main.py
- [ ] Create SQLAlchemy model
- [ ] Uncomment imports
- [ ] Uncomment list endpoint queries
- [ ] Uncomment detail endpoint queries
- [ ] Uncomment resolve endpoint logic
- [ ] Implement notification queueing
- [ ] Test all 10 scenarios
- [ ] Write unit tests
- [ ] Deploy to staging
- [ ] Frontend team tests
- [ ] Deploy to production

---

## 🎯 3 Endpoints to Implement

1. **GET** `/api/v1/admin/reviews/takedown-requests` - List with filters
2. **GET** `/api/v1/admin/reviews/takedown-requests/{id}` - Get details
3. **POST** `/api/v1/admin/reviews/takedown-requests/{id}/resolve` - Accept/Reject

---

## 🚀 Ready to Go!

**Everything you need is in:**
- `IMPLEMENTATION_reviews_takedown.py` - The code
- `IMPLEMENTATION_GUIDE_reviews_takedown.md` - The instructions

**Questions?** Check the troubleshooting section in the guide.

**Let's ship it!** 🎉
