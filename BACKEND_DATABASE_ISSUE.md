# Backend Database Schema Issue - Login Failure

**Date**: November 4, 2025  
**Severity**: 🔴 CRITICAL - Blocks all login functionality  
**Component**: Backend API (appydex_api Docker container)  
**Status**: UNRESOLVED

---

## Issue Summary

The admin login endpoint (`POST /api/v1/auth/login`) is returning **500 Internal Server Error** due to a database schema mismatch in the `refresh_tokens` table.

---

## Error Details

### HTTP Response
```http
HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "code": "INTERNAL_ERROR",
  "message": "Something went wrong",
  "details": {}
}
```

### Backend Error Log
```
sqlalchemy.exc.ProgrammingError: (psycopg2.errors.UndefinedColumn) 
column "token_hash" of relation "refresh_tokens" does not exist

LINE 1: INSERT INTO refresh_tokens (user_id, token_hash, jti, expire...
                                             ^

[SQL: INSERT INTO refresh_tokens (user_id, token_hash, jti, expires_at, 
revoked, revoked_at, last_used_at, user_agent, ip_address) 
VALUES (%(user_id)s::UUID, %(token_hash)s, %(jti)s, %(expires_at)s, 
%(revoked)s, %(revoked_at)s, %(last_used_at)s, %(user_agent)s, %(ip_address)s) 
RETURNING refresh_tokens.id, refresh_tokens.created_at]
```

### Stack Trace Location
- **File**: `/app/app/services/auth_tokens.py`, line 85
- **Function**: `issue_pair` → `_store_refresh`
- **Error**: Attempting to insert `token_hash` column that doesn't exist

---

## Reproduction Steps

1. **Navigate to**: `http://localhost:42319/` (Admin Panel)
2. **Enter credentials**:
   - Email: `admin@appydex.local`
   - Password: `admin123!@#`
   - OTP: `000000`
3. **Click**: Sign In
4. **Result**: Error message "Cannot connect to server"

### Direct API Test
```bash
curl -v http://localhost:16110/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"admin@appydex.local","password":"admin123!@#","otp":"000000"}'

# Returns: 500 Internal Server Error
```

---

## Root Cause Analysis

### Current State
- Backend code expects `refresh_tokens` table to have a `token_hash` column
- Database schema does NOT have this column
- Code tries to INSERT with `token_hash` → Database rejects with UndefinedColumn error

### Migration Status
```bash
$ docker exec appydex_api alembic current
2f6d5f68b472 (head)
```

Migration is at HEAD, but the database schema doesn't match the SQLAlchemy model.

---

## Impact

### Affected Functionality
- ❌ Admin login (all roles)
- ❌ Token refresh
- ❌ All authenticated endpoints
- ❌ Admin panel completely inaccessible

### Working Functionality
- ✅ API health endpoints (`/healthz`, `/readyz`)
- ✅ OpenAPI documentation (`/openapi/v1.json`)
- ✅ Public endpoints (if any)

---

## Required Fix

### Option 1: Run Pending Migration (Recommended)
```bash
# Check for pending migrations
docker exec appydex_api alembic heads

# Upgrade to latest
docker exec appydex_api alembic upgrade head

# Restart container
docker restart appydex_api
```

### Option 2: Manual Schema Update
```sql
-- Connect to database
docker exec -it appydex_postgres psql -U <username> -d appydex

-- Add missing column
ALTER TABLE refresh_tokens 
ADD COLUMN token_hash VARCHAR(255);

-- Verify
\d refresh_tokens
```

### Option 3: Rebuild Database
```bash
# WARNING: This will delete all data
docker-compose down -v
docker-compose up -d
docker exec appydex_api alembic upgrade head
```

---

## Verification Steps

After applying the fix:

1. **Test login via curl**:
```bash
curl -X POST http://localhost:16110/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email_or_phone":"admin@appydex.local","password":"admin123!@#","otp":"000000"}'
```

Expected response:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "user": { ... }
}
```

2. **Test via Admin Panel**:
   - Navigate to `http://localhost:42319/`
   - Login with admin credentials
   - Should redirect to `/dashboard` or `/admins`

---

## Environment Details

### Backend Container
- **Container**: `appydex_api` (ID: c8798d2aa3ef)
- **Image**: `infra-api`
- **Port Mapping**: `0.0.0.0:16110->8000/tcp`
- **Status**: Up 20 minutes (healthy)
- **Uptime**: 36 hours

### Database Container
- **Container**: `appydex_postgres` (ID: 3f38c666701a)
- **Image**: `postgres:15`
- **Port Mapping**: `0.0.0.0:5432->5432/tcp`
- **Status**: Up 9 hours (healthy)

### Migration Version
- **Current**: `2f6d5f68b472 (head)`
- **Migration**: `add_service_type_requests_table`

---

## Additional Context

### Related Code
- **Auth Service**: `/app/app/services/auth_tokens.py`
- **Auth Router**: `/app/app/routers/auth.py`
- **RefreshToken Model**: Check SQLAlchemy model definition

### Expected Table Schema
The `refresh_tokens` table should have these columns:
- `id` (primary key)
- `user_id` (UUID)
- **`token_hash`** ← **MISSING**
- `jti` (JWT ID)
- `expires_at`
- `revoked` (boolean)
- `revoked_at`
- `last_used_at`
- `user_agent`
- `ip_address`
- `created_at`

---

## Action Items

- [ ] Backend team to investigate why `token_hash` column is missing
- [ ] Run appropriate database migration
- [ ] Verify login works after fix
- [ ] Check if other tables have similar schema drift
- [ ] Update deployment documentation with migration steps
- [ ] Consider adding automated schema validation in CI/CD

---

## Contact

**Reporter**: Admin Panel Development Team  
**Priority**: P0 - Critical  
**Assignee**: Backend Infrastructure Team

---

## Notes

The admin panel frontend is working correctly - all recent fixes have been applied successfully:
- ✅ User-friendly error messages
- ✅ OTP field visible
- ✅ Token storage integration
- ✅ Correct API request format
- ✅ Consistent UI layout

This is purely a backend database schema issue.
