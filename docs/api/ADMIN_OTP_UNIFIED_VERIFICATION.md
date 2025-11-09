# Admin OTP Unified Field Verification Guide

**Date:** November 5, 2025  
**Feature:** Unified `email_or_phone` field for admin OTP and login  
**Status:** ✅ Frontend Ready | ⏳ Backend Validation Pending

---

## Overview

The admin authentication flow now accepts a **unified `email_or_phone` field** that automatically detects whether the input is an email (contains "@") or phone number, routing to the correct OTP channel.

### Changes Summary

**Backend (`auth.py`):**
- ✅ Added `AdminRequestOtpBody` Pydantic model
- ✅ Added `AdminLoginBody` Pydantic model
- ✅ Auto-detection logic: email if "@" present, else phone
- ✅ Correct Redis key creation (`otp:{phone}` or `eotp:{email}`)
- ✅ OTP returned in response for dev/testing when Redis unavailable
- ✅ Backward compatibility: query params still work

**Frontend (`appydex-admin`):**
- ✅ Already using `email_or_phone` field (no changes needed)
- ✅ Located in: `lib/core/auth/auth_service.dart` (lines 68-72)

---

## Backend Syntax Validation Checklist

### 1. Python Syntax Check

**If you have the backend code, run:**

```bash
# Navigate to backend repo
cd /path/to/appydex-backend

# Check for syntax errors
python3 -m py_compile app/routers/auth.py

# Expected output: (no output = success)
```

**If syntax errors:**
```
  File "app/routers/auth.py", line 123
    if email_or_phone
                    ^
SyntaxError: invalid syntax
```

---

### 2. Type Validation (Pydantic Models)

**Verify Pydantic models are correctly defined:**

```python
# Expected structure in auth.py

from pydantic import BaseModel, Field
from typing import Optional

class AdminRequestOtpBody(BaseModel):
    """Unified OTP request body accepting email, phone, or unified field"""
    email: Optional[str] = None
    phone: Optional[str] = None
    email_or_phone: Optional[str] = None
    
    @validator('email_or_phone', always=True)
    def validate_at_least_one_identifier(cls, v, values):
        """Ensure at least one identifier is provided"""
        if not v and not values.get('email') and not values.get('phone'):
            raise ValueError('Either email, phone, or email_or_phone must be provided')
        return v

class AdminLoginBody(BaseModel):
    """Unified login body with OTP and password"""
    email: Optional[str] = None
    phone: Optional[str] = None
    email_or_phone: Optional[str] = None
    otp: str = Field(..., min_length=6, max_length=6)
    password: str = Field(..., min_length=8)
    
    @validator('email_or_phone', always=True)
    def validate_at_least_one_identifier(cls, v, values):
        if not v and not values.get('email') and not values.get('phone'):
            raise ValueError('Either email, phone, or email_or_phone must be provided')
        return v
```

**Common Type Issues to Check:**

| Issue | Fix |
|-------|-----|
| ❌ `Optional[str]` imported incorrectly | ✅ `from typing import Optional` |
| ❌ Missing `@validator` decorator | ✅ `from pydantic import validator` |
| ❌ Wrong field type (e.g., `str` instead of `Optional[str]`) | ✅ Use `Optional[str]` for optional fields |
| ❌ Missing `Field(...)` for required fields | ✅ Use `Field(...)` for constraints |

---

### 3. Logic Validation (Email vs Phone Detection)

**Expected detection logic in endpoint:**

```python
@router.post("/api/v1/admin/auth/request-otp")
async def admin_request_otp(
    body: AdminRequestOtpBody = Body(...),
    # ... other params
):
    # Merge query params with body
    email = body.email or query_param_email
    phone = body.phone or query_param_phone
    email_or_phone = body.email_or_phone
    
    # Auto-detect unified field
    if email_or_phone:
        if "@" in email_or_phone:
            email = email_or_phone
            phone = None
        else:
            phone = email_or_phone
            email = None
    
    # Validate at least one identifier
    if not email and not phone:
        raise HTTPException(400, "Either phone or email is required")
    
    # Route to correct channel
    if email:
        # Email OTP flow
        redis_key = f"eotp:{email}"
        # ... generate OTP, send email, store in Redis
        return {
            "message": "OTP sent successfully",
            "otp_sent": {
                "email": True,
                "otp_email": otp_code if DEV_MODE else None
            },
            "requires_password": True
        }
    else:
        # Phone OTP flow
        redis_key = f"otp:{phone}"
        # ... generate OTP, send SMS, store in Redis
        return {
            "message": "OTP sent successfully",
            "otp_sent": {
                "phone": True,
                "otp_phone": otp_code if DEV_MODE else None
            },
            "requires_password": True
        }
```

**Edge Cases to Validate:**

| Case | Expected Behavior |
|------|-------------------|
| `email_or_phone="admin@example.com"` | ✅ Detected as email, uses `eotp:{email}` key |
| `email_or_phone="+15551234567"` | ✅ Detected as phone, uses `otp:{phone}` key |
| `email_or_phone="johndoe"` (no @) | ✅ Treated as phone, uses `otp:johndoe` key |
| Both `email` and `email_or_phone` provided | ✅ `email_or_phone` takes precedence |
| Query param + body field | ✅ Body field takes precedence |
| Neither field provided | ❌ Returns 400: "Either phone or email is required" |

---

### 4. Redis Key Validation

**Check Redis keys are created correctly:**

```bash
# After OTP request, check Redis (if available)

# For email OTP:
redis-cli
> KEYS eotp:*
1) "eotp:admin@example.com"
> GET eotp:admin@example.com
"123456"
> TTL eotp:admin@example.com
(integer) 298  # Should be ~300 seconds

# For phone OTP:
> KEYS otp:*
1) "otp:+15551234567"
> GET otp:+15551234567
"789012"
> TTL otp:+15551234567
(integer) 295
```

**If Redis is unavailable:**
- OTP should still be generated
- OTP should be returned in response (dev mode)
- Login should work with returned OTP

---

## End-to-End Verification Steps

### Setup Prerequisites

```bash
# 1. Backend running
cd /path/to/appydex-backend
source venv/bin/activate  # or your virtualenv
uvicorn app.main:app --host 0.0.0.0 --port 16110 --reload

# 2. Frontend running
cd /home/devin/Desktop/APPYDEX/appydex-admin
flutter run -d chrome --web-port=46633

# 3. Redis running (optional for testing)
redis-server  # or docker-compose up redis
```

---

### Test 1: Email OTP via JSON Body (Unified Field)

**Request:**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "admin@example.com"
  }'
```

**Expected Response (200):**
```json
{
  "message": "OTP sent successfully",
  "otp_sent": {
    "email": true,
    "otp_email": "000000"
  },
  "requires_password": true
}
```

**Validation Checklist:**
- ✅ Status code: 200
- ✅ `otp_sent.email === true`
- ✅ `otp_sent.otp_email` present (dev mode)
- ✅ Redis key exists: `eotp:admin@example.com` (if Redis connected)
- ✅ TTL is ~300 seconds

**If Redis connected, verify:**
```bash
redis-cli GET eotp:admin@example.com
# Output: "000000" (or actual OTP)
```

---

### Test 2: Phone OTP via JSON Body (Unified Field)

**Request:**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "+15551234567"
  }'
```

**Expected Response (200):**
```json
{
  "message": "OTP sent successfully",
  "otp_sent": {
    "phone": true,
    "otp_phone": "000000"
  },
  "requires_password": true
}
```

**Validation Checklist:**
- ✅ Status code: 200
- ✅ `otp_sent.phone === true`
- ✅ `otp_sent.otp_phone` present (dev mode)
- ✅ Redis key exists: `otp:+15551234567`

---

### Test 3: Login with Email (Unified Field)

**Step 1: Request OTP**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{"email_or_phone": "admin@example.com"}'
```

**Step 2: Login with OTP**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "admin@example.com",
    "otp": "000000",
    "password": "YourSecurePassword123!"
  }'
```

**Expected Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 900,
  "roles": ["super_admin"],
  "active_role": "super_admin",
  "user_id": 1,
  "message": "Welcome back, admin@example.com!"
}
```

**Validation Checklist:**
- ✅ Status code: 200
- ✅ `access_token` present and valid JWT
- ✅ `refresh_token` present
- ✅ `roles` array contains admin roles
- ✅ `active_role` is set
- ✅ `user_id` matches admin user
- ✅ Can use access token to call admin endpoints

**Verify JWT:**
```bash
# Decode JWT to verify contents
echo "YOUR_ACCESS_TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq
# Should show: {"sub": "1", "roles": ["super_admin"], "exp": 1730841000, ...}
```

---

### Test 4: Login with Phone (Unified Field)

**Step 1: Request OTP**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{"email_or_phone": "+15551234567"}'
```

**Step 2: Login**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "+15551234567",
    "otp": "000000",
    "password": "YourPassword123!"
  }'
```

**Expected:** Same as Test 3 (200 with tokens)

---

### Test 5: Backward Compatibility (Query Params)

**Email via Query Param:**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp?email=admin@example.com'
```

**Phone via Query Param:**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp?phone=%2B15551234567'
```

**Expected:** Both should work (200 response)

---

### Test 6: Frontend Integration

**1. Open Admin Panel:**
```bash
# Navigate to
http://localhost:46633/
```

**2. Login with Email:**
- Enter: `admin@example.com`
- Password: `Admin@123` (or your test password)
- OTP: `000000` (dev mode)
- Click: **Sign In**

**Expected:**
- ✅ Redirects to `/dashboard` or `/admins`
- ✅ User session persists on page refresh
- ✅ Can access admin endpoints

**3. Check Browser DevTools:**
```javascript
// Open Console (F12)
// Look for logs:
// LOGIN PAYLOAD: {"email_or_phone":"admin@example.com","password":"***","otp":"000000"}
// LOGIN RESPONSE: {"access_token":"...","roles":["super_admin"],...}
```

**4. Verify Network Tab:**
- ✅ POST request to `/api/v1/admin/auth/login`
- ✅ Request body: `{"email_or_phone":"admin@example.com",...}`
- ✅ Response status: 200
- ✅ Response contains `access_token`, `refresh_token`, `roles`

---

### Test 7: Error Handling

**Test 7.1: Missing Identifier**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{}'
```

**Expected (400):**
```json
{
  "detail": [
    {
      "type": "value_error",
      "msg": "Either email, phone, or email_or_phone must be provided"
    }
  ]
}
```

**Test 7.2: Invalid OTP**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "admin@example.com",
    "otp": "999999",
    "password": "Admin@123"
  }'
```

**Expected (401):**
```json
{
  "detail": "Invalid or expired OTP"
}
```

**Test 7.3: Invalid Password**
```bash
curl -X POST 'http://localhost:16110/api/v1/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email_or_phone": "admin@example.com",
    "otp": "000000",
    "password": "WrongPassword"
  }'
```

**Expected (401):**
```json
{
  "detail": "Invalid password"
}
```

**Test 7.4: Non-Admin User**
```bash
# Try with a regular user (non-admin)
curl -X POST 'http://localhost:16110/api/v1/admin/auth/request-otp' \
  -H 'Content-Type: application/json' \
  -d '{"email_or_phone": "user@example.com"}'
```

**Expected (403):**
```json
{
  "detail": "User does not have admin privileges"
}
```

---

## Common Issues & Troubleshooting

### Issue 1: "Either phone or email is required"

**Symptoms:**
- 400 response even when `email_or_phone` is provided

**Check:**
1. Request body is valid JSON
2. Content-Type header is `application/json`
3. Field name is exactly `email_or_phone` (no typos)

**Debug:**
```python
# Add logging in backend endpoint
print(f"Received body: {body}")
print(f"email_or_phone value: {body.email_or_phone}")
```

---

### Issue 2: Wrong Redis Key Created

**Symptoms:**
- Email sent as phone (or vice versa)
- Redis key is `otp:admin@example.com` instead of `eotp:admin@example.com`

**Check:**
- Detection logic: `if "@" in email_or_phone`
- Email extraction: `email = email_or_phone if "@" in email_or_phone else None`
- Phone extraction: `phone = email_or_phone if "@" not in email_or_phone else None`

**Debug:**
```python
print(f"Detected email: {email}, phone: {phone}")
print(f"Redis key will be: {'eotp:' + email if email else 'otp:' + phone}")
```

---

### Issue 3: OTP Not Returned in Dev Mode

**Symptoms:**
- Response doesn't include `otp_email` or `otp_phone`

**Check:**
1. Dev mode is enabled: `DEV_MODE = os.getenv("DEV_MODE", "false").lower() == "true"`
2. Redis is unavailable (intentional for testing)
3. Response builder includes OTP:
```python
return {
    "otp_sent": {
        "email": True,
        "otp_email": otp_code if (DEV_MODE or not redis_available) else None
    }
}
```

---

### Issue 4: Frontend Not Sending Unified Field

**Symptoms:**
- Backend logs show `email_or_phone: None`

**Check:**
```dart
// In lib/core/auth/auth_service.dart (line ~68)
final payload = {
  'email_or_phone': email.trim(),  // ✅ Should be this
  'password': password.trim(),
  'otp': otp.trim(),
};

// ❌ NOT this:
final payload = {
  'email': email.trim(),  // Wrong: old field name
  'password': password.trim(),
  'otp': otp.trim(),
};
```

---

### Issue 5: JWT Token Invalid

**Symptoms:**
- Login succeeds but subsequent admin calls return 401

**Check:**
1. Token is being saved: `await _tokenStorage.save(TokenPair(access, refresh))`
2. Token is being sent: `Authorization: Bearer ${accessToken}`
3. Token is not expired (check `exp` claim)

**Debug:**
```bash
# Decode JWT
echo "YOUR_TOKEN" | cut -d'.' -f2 | base64 -d | jq

# Check expiry
{
  "exp": 1730841000,  # Unix timestamp
  "iat": 1730840100,
  "sub": "1",
  "roles": ["super_admin"]
}

# Convert exp to human readable
date -d @1730841000
# Should be > current time
```

---

## Success Criteria

### Backend Validation ✅

- [ ] `auth.py` has no Python syntax errors
- [ ] `AdminRequestOtpBody` and `AdminLoginBody` defined correctly
- [ ] Email detection logic: `if "@" in email_or_phone`
- [ ] Phone detection logic: `else` branch
- [ ] Redis keys created correctly: `eotp:{email}` or `otp:{phone}`
- [ ] OTP returned in response (dev mode)
- [ ] Query param compatibility maintained

### End-to-End ✅

- [ ] Email OTP request works (curl)
- [ ] Phone OTP request works (curl)
- [ ] Email login works (curl)
- [ ] Phone login works (curl)
- [ ] Frontend login works (browser)
- [ ] Session persists on refresh
- [ ] Admin endpoints accessible with token
- [ ] Error cases handled correctly

### Production Readiness ✅

- [ ] Redis TTL configured (300s)
- [ ] Rate limiting enabled (30s cooldown)
- [ ] Attempt limiting enabled (5 max)
- [ ] OTP not returned in production (only dev)
- [ ] SMS/Email sending working (not mocked)
- [ ] Audit logs capturing auth events
- [ ] HTTPS enabled (production)

---

## Next Steps

### Option 1: Backend Validation (Recommended First)

If you have access to the backend code:

1. **Run Python syntax check:**
   ```bash
   cd /path/to/appydex-backend
   python3 -m py_compile app/routers/auth.py
   ```

2. **Run backend tests:**
   ```bash
   pytest tests/test_admin_auth.py -v
   ```

3. **Manual curl tests** (use Test 1-7 above)

### Option 2: Frontend Verification (Already Done)

Frontend is already ready! No changes needed.

### Option 3: Full Stack Integration Test

Run both backend and frontend, then:

1. Open browser to `http://localhost:46633/`
2. Login with email: `admin@example.com`
3. Verify success

---

## Automation Script

**Complete verification script:**

```bash
#!/bin/bash
# verify_admin_otp_unified.sh

set -e

BASE_URL="${API_BASE_URL:-http://localhost:16110}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin@123}"

echo "🔍 Admin OTP Unified Field Verification"
echo "========================================"
echo "Base URL: $BASE_URL"
echo ""

# Test 1: Email OTP Request
echo "✅ Test 1: Email OTP Request (Unified Field)"
RESPONSE=$(curl -s -w "\nSTATUS:%{http_code}" \
  -X POST "$BASE_URL/api/v1/admin/auth/request-otp" \
  -H 'Content-Type: application/json' \
  -d "{\"email_or_phone\": \"$ADMIN_EMAIL\"}")

STATUS=$(echo "$RESPONSE" | grep "STATUS:" | cut -d':' -f2)
BODY=$(echo "$RESPONSE" | grep -v "STATUS:")

if [ "$STATUS" = "200" ]; then
  echo "✅ Status: 200"
  echo "$BODY" | jq .
  OTP_EMAIL=$(echo "$BODY" | jq -r '.otp_sent.otp_email // "000000"')
  echo "OTP Email: $OTP_EMAIL"
else
  echo "❌ Status: $STATUS"
  echo "$BODY"
  exit 1
fi

echo ""

# Test 2: Email Login
echo "✅ Test 2: Email Login (Unified Field)"
LOGIN_RESPONSE=$(curl -s -w "\nSTATUS:%{http_code}" \
  -X POST "$BASE_URL/api/v1/admin/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{
    \"email_or_phone\": \"$ADMIN_EMAIL\",
    \"otp\": \"$OTP_EMAIL\",
    \"password\": \"$ADMIN_PASSWORD\"
  }")

LOGIN_STATUS=$(echo "$LOGIN_RESPONSE" | grep "STATUS:" | cut -d':' -f2)
LOGIN_BODY=$(echo "$LOGIN_RESPONSE" | grep -v "STATUS:")

if [ "$LOGIN_STATUS" = "200" ]; then
  echo "✅ Status: 200"
  echo "$LOGIN_BODY" | jq .
  ACCESS_TOKEN=$(echo "$LOGIN_BODY" | jq -r '.access_token')
  echo "Access Token: ${ACCESS_TOKEN:0:50}..."
else
  echo "❌ Status: $LOGIN_STATUS"
  echo "$LOGIN_BODY"
  exit 1
fi

echo ""

# Test 3: Use Token to Access Admin Endpoint
echo "✅ Test 3: Access Admin Endpoint with Token"
ADMIN_RESPONSE=$(curl -s -w "\nSTATUS:%{http_code}" \
  -X GET "$BASE_URL/api/v1/admin/accounts" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

ADMIN_STATUS=$(echo "$ADMIN_RESPONSE" | grep "STATUS:" | cut -d':' -f2)

if [ "$ADMIN_STATUS" = "200" ]; then
  echo "✅ Admin endpoint accessible"
else
  echo "❌ Admin endpoint failed: $ADMIN_STATUS"
  exit 1
fi

echo ""
echo "🎉 All tests passed!"
echo "========================================"
echo "✅ Email OTP request works"
echo "✅ Email login works"
echo "✅ Admin endpoints accessible with token"
echo ""
echo "Backend unified field implementation is working correctly!"
```

**Usage:**
```bash
chmod +x verify_admin_otp_unified.sh
./verify_admin_otp_unified.sh
```

---

## Documentation References

- **Complete Admin API Docs:** [COMPLETE_ADMIN_API.md](COMPLETE_ADMIN_API.md)
- **Frontend Auth Service:** `lib/core/auth/auth_service.dart`
- **Backend Auth Router:** `app/routers/auth.py` (backend repo)
- **Admin Management Guide:** [ADMIN_MANAGEMENT_GUIDE.md](ADMIN_MANAGEMENT_GUIDE.md)

---

**Last Updated:** November 5, 2025  
**Status:** ✅ Frontend Ready | ⏳ Backend Validation Pending  
**Next Action:** Run backend syntax validation and curl tests
