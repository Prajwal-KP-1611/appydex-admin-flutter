# 🔴 URGENT: CORS Configuration Required

**Status:** ⚠️ BLOCKING - Frontend cannot make any API calls  
**Date:** 2025-11-07  
**Priority:** 🔴 CRITICAL - Must be deployed immediately

## Problem

The admin frontend at `http://localhost:*` cannot make requests to the backend API at `https://api.appydex.co` due to missing CORS headers.

**Error:**
```
Access to XMLHttpRequest at 'https://api.appydex.co/api/v1/admin/auth/request-otp' 
from origin 'http://localhost:61101' has been blocked by CORS policy: 
Response to preflight request doesn't pass access control check: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## Required Solution

Add CORS middleware to the backend server with these settings:

### FastAPI/Starlette (Python)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Add this IMMEDIATELY after app initialization
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:*",           # Local development (all ports)
        "http://127.0.0.1:*",           # Local development alternative
        "https://admin.appydex.com",     # Production frontend
        "https://admin.appydex.co",      # Alternative production domain
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "Content-Type",
        "Authorization",
        "Idempotency-Key",
        "X-Request-ID",
    ],
    expose_headers=[
        "X-Request-ID",
        "X-RateLimit-Limit",
        "X-RateLimit-Remaining",
        "X-RateLimit-Reset",
    ],
    max_age=600,  # Cache preflight requests for 10 minutes
)
```

**Note:** FastAPI/Starlette doesn't support wildcard ports in `allow_origins`. For development, you may need to use regex:

```python
import re
from fastapi.middleware.cors import CORSMiddleware

# Alternatively, use regex patterns
origins_regex = r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$"

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=origins_regex,
    allow_origins=[
        "https://admin.appydex.com",
        "https://admin.appydex.co",
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization", "Idempotency-Key", "X-Request-ID"],
    expose_headers=["X-Request-ID", "X-RateLimit-Limit", "X-RateLimit-Remaining"],
    max_age=600,
)
```

### Express/Node.js

```javascript
const express = require('express');
const cors = require('cors');

const app = express();

// Add this BEFORE any routes
app.use(cors({
  origin: [
    /^https?:\/\/localhost:\d+$/,        // Local development (all ports)
    /^https?:\/\/127\.0\.0\.1:\d+$/,     // Local development alternative
    'https://admin.appydex.com',          // Production frontend
    'https://admin.appydex.co',           // Alternative production domain
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'Idempotency-Key',
    'X-Request-ID',
  ],
  exposedHeaders: [
    'X-Request-ID',
    'X-RateLimit-Limit',
    'X-RateLimit-Remaining',
    'X-RateLimit-Reset',
  ],
  maxAge: 600,
}));
```

### Django (Python)

```python
# settings.py

INSTALLED_APPS = [
    # ...
    'corsheaders',
    # ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Must be BEFORE CommonMiddleware
    'django.middleware.common.CommonMiddleware',
    # ...
]

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "https://admin.appydex.com",
    "https://admin.appydex.co",
]

CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https?://localhost:\d+$",
    r"^https?://127\.0\.0\.1:\d+$",
]

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS',
]

CORS_ALLOW_HEADERS = [
    'content-type',
    'authorization',
    'idempotency-key',
    'x-request-id',
]

CORS_EXPOSE_HEADERS = [
    'x-request-id',
    'x-ratelimit-limit',
    'x-ratelimit-remaining',
    'x-ratelimit-reset',
]

CORS_PREFLIGHT_MAX_AGE = 600
```

## Testing CORS Configuration

After deploying the CORS middleware, test with:

```bash
# Test preflight request (OPTIONS)
curl -X OPTIONS https://api.appydex.co/api/v1/admin/auth/request-otp \
  -H "Origin: http://localhost:61101" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type,Authorization" \
  -v

# Expected response headers:
# HTTP/1.1 200 OK (or 204 No Content)
# Access-Control-Allow-Origin: http://localhost:61101
# Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
# Access-Control-Allow-Headers: Content-Type, Authorization, Idempotency-Key, X-Request-ID
# Access-Control-Allow-Credentials: true
# Access-Control-Max-Age: 600
```

```bash
# Test actual POST request
curl -X POST https://api.appydex.co/api/v1/admin/auth/request-otp \
  -H "Origin: http://localhost:61101" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' \
  -v

# Expected response headers:
# Access-Control-Allow-Origin: http://localhost:61101
# Access-Control-Allow-Credentials: true
```

## Security Considerations

1. ✅ **Development Origins:** Using regex patterns for `localhost:*` and `127.0.0.1:*` is safe for development
2. ✅ **Production Origins:** Explicitly list production domains (no wildcards)
3. ✅ **Credentials:** `allow_credentials=true` is needed for cookie-based auth (if implemented)
4. ✅ **Methods:** Only allow methods actually used by the API
5. ✅ **Headers:** Only expose headers that the frontend needs
6. ⚠️ **DO NOT:** Use `allow_origins=["*"]` with `allow_credentials=true` (browsers will reject it)

## Deployment Checklist

- [ ] Add CORS middleware to backend application
- [ ] Deploy to staging/development environment (`https://api.appydex.co`)
- [ ] Test with curl commands above
- [ ] Verify frontend can make requests from `localhost:*`
- [ ] Test with actual frontend login flow
- [ ] Document configuration in backend README
- [ ] Plan production deployment with `https://admin.appydex.com` origin

## Impact

**Without CORS:** Frontend is **completely non-functional** - cannot authenticate, fetch data, or perform any operations.

**With CORS:** Frontend can communicate with backend normally for development and testing.

## Questions?

Contact frontend team immediately if:
- The backend framework is different from examples above
- There are existing CORS settings that need to be modified
- Security team has additional requirements
- Need help with implementation

---

**This is blocking all frontend development and testing. Please prioritize.**
