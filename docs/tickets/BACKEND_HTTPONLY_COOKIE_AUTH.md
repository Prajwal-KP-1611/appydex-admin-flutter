# Backend Request: httpOnly Cookie Authentication

**Priority**: HIGH  
**Category**: Security / Authentication  
**Status**: PENDING BACKEND IMPLEMENTATION

---

## Problem Statement

Current web implementation uses in-memory token storage, which means:
- ❌ Users logged out on browser refresh
- ❌ Poor UX for web admin panel
- ❌ Cannot maintain sessions across page reloads

The current approach was implemented to mitigate XSS attacks (tokens previously stored in localStorage), but it creates a poor user experience.

---

## Solution: httpOnly Cookie-Based Authentication

Implement a secure, production-ready authentication flow using httpOnly cookies for refresh tokens.

### Architecture Overview

```
┌─────────────┐                 ┌─────────────┐
│   Browser   │                 │   Backend   │
│  (Frontend) │                 │   (API)     │
└─────────────┘                 └─────────────┘
       │                               │
       │  1. POST /auth/login          │
       │  (email, password/OTP)        │
       │ ─────────────────────────────>│
       │                               │
       │  2. Set-Cookie: refresh_token │
       │     (httpOnly, Secure)        │
       │  Response: { access_token }   │
       │ <─────────────────────────────│
       │                               │
       │  3. Store access_token in     │
       │     memory (JavaScript var)   │
       │                               │
       │  --- PAGE REFRESH OCCURS ---  │
       │                               │
       │  4. POST /auth/refresh        │
       │  Cookie: refresh_token        │
       │ ─────────────────────────────>│
       │                               │
       │  5. Validate cookie           │
       │  Response: { access_token }   │
       │ <─────────────────────────────│
       │                               │
       │  6. Store new access_token    │
       │     User stays logged in!     │
       │                               │
```

---

## Required Backend Changes

### 1. Update Login Endpoint

**Endpoint**: `POST /api/v1/admin/auth/verify-otp`  
**Current Response**:
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "token_type": "Bearer",
  "admin": { ... }
}
```

**New Response** (refresh_token removed from body):
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "Bearer",
  "admin": { ... }
}
```

**New Response Headers**:
```http
Set-Cookie: refresh_token=eyJhbGc...; HttpOnly; Secure; SameSite=Strict; Path=/api/v1/admin/auth; Max-Age=2592000
```

**Cookie Attributes**:
- `HttpOnly`: Prevents JavaScript access (XSS protection)
- `Secure`: Only sent over HTTPS (MITM protection)
- `SameSite=Strict`: CSRF protection
- `Path=/api/v1/admin/auth`: Limit scope to auth endpoints
- `Max-Age=2592000`: 30 days (configurable)

### 2. Create Refresh Endpoint

**NEW Endpoint**: `POST /api/v1/admin/auth/refresh`

**Request**:
- No body required
- Cookie header automatically sent by browser: `Cookie: refresh_token=eyJhbGc...`

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "Bearer"
}
```

**Response Headers** (optional, to rotate refresh token):
```http
Set-Cookie: refresh_token=<new_token>; HttpOnly; Secure; SameSite=Strict; Path=/api/v1/admin/auth; Max-Age=2592000
```

**Error Responses**:
- `401 Unauthorized`: Invalid/expired refresh token
  ```json
  {
    "detail": "Invalid or expired refresh token"
  }
  ```

**Backend Logic**:
1. Read `refresh_token` from cookie
2. Validate JWT signature and expiration
3. Check if token revoked (optional: maintain revocation list)
4. Generate new access token
5. Optionally: Rotate refresh token (issue new one)
6. Return new access token

### 3. Update Logout Endpoint

**Endpoint**: `POST /api/v1/admin/auth/logout`

**Current Behavior**: Server-side session cleanup (if any)

**New Behavior**: 
1. Perform existing logout logic
2. **Clear the refresh token cookie**

**Response Headers**:
```http
Set-Cookie: refresh_token=; HttpOnly; Secure; SameSite=Strict; Path=/api/v1/admin/auth; Max-Age=0
```

(Setting `Max-Age=0` deletes the cookie)

---

## Frontend Changes (Our Side)

### 1. Update Auth Repository

**File**: `lib/repositories/auth_repo.dart`

Add refresh method:
```dart
Future<TokenPair> refreshAccessToken() async {
  final response = await _client.requestAdmin<Map<String, dynamic>>(
    '/admin/auth/refresh',
    method: 'POST',
  );
  
  // Backend returns only access_token in response body
  // refresh_token comes from httpOnly cookie (managed by browser)
  final accessToken = response.data?['access_token'] as String;
  
  // We still create a TokenPair but with empty refresh token
  // (it's in the cookie, not accessible to us)
  return TokenPair(
    accessToken: accessToken,
    refreshToken: '', // Not stored on web
  );
}
```

### 2. Add App Initialization Logic

**File**: `lib/main.dart` or `lib/core/app_init.dart`

On app startup:
```dart
Future<void> initializeAuth() async {
  try {
    // Try to refresh access token from httpOnly cookie
    final newTokens = await authRepo.refreshAccessToken();
    
    // Store new access token in memory
    await tokenStorage.save(newTokens);
    
    // User is logged in!
  } catch (e) {
    // No valid refresh token cookie, user needs to login
    await tokenStorage.clear();
  }
}
```

### 3. Update Token Storage

**File**: `lib/core/auth/token_storage.dart`

No changes needed! Already stores access token in memory.

### 4. Update Dio Configuration

**File**: `lib/core/api_client.dart`

Ensure credentials are sent with requests:
```dart
_dio = Dio(BaseOptions(
  baseURL: apiBaseUrl,
  // IMPORTANT: Send cookies with cross-origin requests
  extra: {'withCredentials': true},
));
```

---

## Security Considerations

### ✅ XSS Protection
- Refresh token in httpOnly cookie = **not accessible to JavaScript**
- Access token in memory = **cleared on XSS-triggered refresh**
- Attack window limited to access token lifetime (15 min)

### ✅ CSRF Protection
- `SameSite=Strict` prevents cross-site cookie sending
- Refresh endpoint only accepts POST (not GET)
- Frontend and backend on same domain (api.appydex.co)

### ✅ Token Rotation
- Backend can rotate refresh tokens on each refresh call
- Old refresh tokens invalidated after use
- Limits impact of token theft

### ⚠️ HTTPS Required
- `Secure` flag requires HTTPS in production
- Development: Use `Secure` flag conditionally or test with HTTPS locally

---

## Implementation Checklist

### Backend Tasks:
- [ ] Update `/auth/verify-otp` to set httpOnly cookie
- [ ] Implement `/auth/refresh` endpoint
- [ ] Update `/auth/logout` to clear cookie
- [ ] Configure CORS to allow credentials:
  ```python
  # FastAPI example
  app.add_middleware(
      CORSMiddleware,
      allow_credentials=True,  # CRITICAL
      allow_origins=["https://admin.appydex.co"],
      allow_methods=["*"],
      allow_headers=["*"],
  )
  ```
- [ ] Test cookie flow with frontend
- [ ] Add refresh token rotation (optional but recommended)
- [ ] Implement token revocation list (optional)

### Frontend Tasks (Our Side):
- [ ] Update `auth_repo.dart` with `refreshAccessToken()`
- [ ] Add app initialization logic in `main.dart`
- [ ] Update Dio to send credentials (`withCredentials: true`)
- [ ] Test refresh flow on app startup
- [ ] Handle 401 errors from refresh endpoint
- [ ] Update login flow to not expect `refresh_token` in response body

---

## Testing Plan

### Manual Testing:
1. **Login Flow**:
   - Login with OTP
   - Verify `Set-Cookie` header in browser DevTools (Network tab)
   - Verify cookie visible in Application tab (should show httpOnly=true)
   - Verify access token stored in memory

2. **Refresh Flow**:
   - After login, refresh browser page
   - Verify `/auth/refresh` called automatically
   - Verify new access token received
   - Verify user remains logged in

3. **Logout Flow**:
   - Click logout
   - Verify cookie cleared (Max-Age=0)
   - Refresh page
   - Verify user redirected to login

4. **Security Testing**:
   - Try to access `refresh_token` cookie via JavaScript console: `document.cookie`
   - Should NOT be visible (httpOnly protection)
   - Try refresh endpoint from different origin (should fail with CORS)

### Automated Testing:
- Backend unit tests for refresh endpoint
- Integration test for full auth flow
- Frontend E2E test for refresh-on-reload

---

## Migration Path

### Phase 1: Backend Implementation
1. Implement endpoints (don't deploy yet)
2. Test in staging environment

### Phase 2: Frontend Updates
1. Add refresh logic (feature-flagged)
2. Test against staging backend

### Phase 3: Production Rollout
1. Deploy backend changes
2. Deploy frontend changes
3. Monitor for issues
4. Users will be logged out once (migration)

### Phase 4: Cleanup
1. Remove old token storage logic (if any)
2. Update documentation

---

## Alternative Approaches Considered

### ❌ Store Refresh Token in localStorage
- **Rejected**: XSS vulnerability
- Malicious script can steal tokens

### ❌ Store Both Tokens in Cookies
- **Rejected**: Access token sent with every request (overhead)
- CSRF risk if not careful
- Access token should be short-lived and in memory

### ✅ Current Approach (httpOnly Cookie + Memory)
- **Best balance** of security and UX
- Industry standard (used by Auth0, Firebase, etc.)

---

## References

- OWASP: Token Storage Best Practices
- RFC 6265: HTTP State Management Mechanism (Cookies)
- MDN: Set-Cookie Documentation
- Auth0: Token Storage in Browser

---

## Questions / Discussion

1. **Token Lifetime**: What should be the lifetime for refresh tokens? (Recommended: 30 days)
2. **Token Rotation**: Should refresh tokens be rotated on each refresh? (Recommended: Yes)
3. **Revocation**: Do we need a token revocation list? (Optional, adds complexity)
4. **Multi-Device**: Should logging out on one device invalidate all refresh tokens? (Business decision)

---

**Created**: 2025-11-07  
**Related Tickets**: 
- BACKEND_MISSING_ENDPOINTS.md (Section on Auth)
- PRODUCTION_FEATURES_IMPLEMENTATION.md (Security fixes)

**Frontend PR**: Will be created after backend implementation
