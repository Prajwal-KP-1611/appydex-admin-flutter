# 🔄 Token Refresh Enhancement Proposal

**Date:** November 9, 2025  
**Issue:** Tokens expire and require manual re-login  
**Status:** ⚠️ PARTIALLY IMPLEMENTED - NEEDS ENHANCEMENT

---

## 🔍 CURRENT STATE

### ✅ What's Already Working:

1. **Reactive Token Refresh (Implemented)**
   - File: `lib/core/api_client.dart` (lines 407-555)
   - When request gets 401 → automatically calls `/auth/refresh`
   - Retries original request with new token
   - Uses refresh token from storage or httpOnly cookie (web)

2. **Token Storage**
   - File: `lib/core/auth/token_storage.dart`
   - Stores access_token and refresh_token
   - Web: In-memory only (security)
   - Mobile: Secure storage (Keychain/KeyStore)

3. **Refresh Endpoint Support**
   - Backend has: `POST /api/v1/auth/refresh`
   - Accepts: `refresh_token` in body or httpOnly cookie
   - Returns: New `access_token` and `refresh_token`

### ❌ What's Missing:

**PROACTIVE TOKEN REFRESH** - Refresh BEFORE expiry instead of waiting for 401

---

## 🎯 PROBLEM

**Current Flow (Reactive):**
```
1. User clicks button
2. Request sent with expired token
3. Backend returns 401
4. Frontend auto-refreshes token
5. Frontend retries request
6. Request succeeds
```

**Issues:**
- ⚠️ Extra round-trip (401 + retry)
- ⚠️ Slight delay visible to user
- ⚠️ If refresh fails → user sees error then forced to login

**Better Flow (Proactive):**
```
1. Background timer checks token expiry
2. Token expires in 2 minutes → auto-refresh
3. New tokens stored
4. User clicks button
5. Request sent with fresh token
6. Request succeeds immediately
```

**Benefits:**
- ✅ No 401 errors
- ✅ Seamless UX (user never notices)
- ✅ Logout only when refresh token expires

---

## 🚀 PROPOSED SOLUTION

### Option A: Decode JWT and Check Expiry (RECOMMENDED)

**Requires:**
1. Add `jwt_decode` package to parse JWT tokens
2. Extract `exp` (expiry timestamp) from access token
3. Set up timer to refresh 2-5 minutes before expiry
4. Auto-refresh in background

**Implementation:**

```dart
// pubspec.yaml
dependencies:
  jwt_decode: ^0.3.1

// lib/core/auth/token_manager.dart (NEW FILE)
import 'dart:async';
import 'package:jwt_decode/jwt_decode.dart';

class TokenManager {
  Timer? _refreshTimer;
  
  void startAutoRefresh(String accessToken, VoidCallback onRefresh) {
    _cancelTimer();
    
    try {
      // Decode JWT to get expiry
      final decoded = Jwt.parseJwt(accessToken);
      final exp = decoded['exp'] as int?;
      
      if (exp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        
        // Refresh 2 minutes before expiry
        final refreshTime = expiryDate.subtract(const Duration(minutes: 2));
        final delay = refreshTime.difference(now);
        
        if (delay.isNegative) {
          // Already expired or close to expiry - refresh now
          onRefresh();
        } else {
          // Schedule refresh
          _refreshTimer = Timer(delay, onRefresh);
        }
      }
    } catch (e) {
      debugPrint('[TokenManager] Failed to parse JWT: $e');
    }
  }
  
  void _cancelTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  void dispose() {
    _cancelTimer();
  }
}
```

**Pros:**
- ✅ Most accurate (uses actual token expiry)
- ✅ No backend changes needed
- ✅ Industry standard approach

**Cons:**
- ❌ Adds dependency (jwt_decode: 15KB)
- ❌ Slightly more complex

---

### Option B: Fixed Interval Refresh (SIMPLER)

**Requires:**
- No new packages
- Simple timer that refreshes every X minutes

**Implementation:**

```dart
// lib/core/auth/token_manager.dart (NEW FILE)
class TokenManager {
  Timer? _refreshTimer;
  
  void startAutoRefresh(VoidCallback onRefresh) {
    _cancelTimer();
    
    // Refresh every 10 minutes (assuming 15 min token expiry)
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => onRefresh(),
    );
  }
  
  void _cancelTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  void dispose() {
    _cancelTimer();
  }
}
```

**Pros:**
- ✅ No dependencies
- ✅ Very simple
- ✅ Works with any token expiry time

**Cons:**
- ❌ Not optimal (might refresh too early or too late)
- ❌ Wastes bandwidth if token has long expiry

---

### Option C: Backend Returns Expiry (BEST BUT NEEDS BACKEND)

**Requires:**
- Backend changes to include expiry in response

**Backend Change Needed:**

```python
# Backend: /api/v1/auth/otp/email/verify (and /refresh)
# Current response:
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "admin": {...}
  }
}

# Proposed response:
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "expires_in": 900,        # NEW: seconds until access token expires
    "refresh_expires_in": 604800,  # NEW: seconds until refresh token expires
    "admin": {...}
  }
}
```

**Frontend:**

```dart
class TokenPair {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;  // NEW
  final int refreshExpiresIn;  // NEW
  
  DateTime get expiryTime => 
    DateTime.now().add(Duration(seconds: expiresIn));
}

// Start auto-refresh based on expiresIn
tokenManager.startAutoRefresh(
  expiryTime: tokens.expiryTime,
  onRefresh: () => apiClient.refreshTokens(),
);
```

**Pros:**
- ✅ Most reliable
- ✅ No JWT parsing needed
- ✅ Backend controls refresh timing

**Cons:**
- ❌ Requires backend changes
- ❌ Blocks frontend implementation

---

## 📊 RECOMMENDATION

**SHORT TERM (Today):**
→ **Option B: Fixed Interval Refresh**
- Implement in 30 minutes
- No dependencies
- Immediate improvement
- Refresh every 10 minutes (safe for 15 min tokens)

**LONG TERM (Next Sprint):**
→ **Option C: Backend Returns Expiry**
- Create backend ticket
- Most reliable solution
- Better UX
- Industry standard

---

## 🎯 IMPLEMENTATION PLAN

### Phase 1: Fixed Interval (TODAY)

**Files to Create/Modify:**

1. **Create:** `lib/core/auth/token_manager.dart` (Option B code)

2. **Modify:** `lib/core/api_client.dart`
   - Add TokenManager instance
   - Start timer after successful login
   - Start timer after successful refresh
   - Cancel timer on logout

3. **Test:**
   - Login → wait 10 minutes → verify auto-refresh
   - Check token is refreshed automatically
   - Verify no 401 errors

**Estimated Time:** 30-45 minutes

---

### Phase 2: Backend Expiry Info (NEXT SPRINT)

**Backend Ticket:** `BACKEND-AUTH-EXPIRY-001`

**Requirements:**
1. Add `expires_in` to login response
2. Add `expires_in` to OTP verify response
3. Add `expires_in` to refresh response
4. Add `refresh_expires_in` to all auth responses

**Frontend Changes:**
1. Update `TokenPair` model with expiry fields
2. Implement Option A (decode JWT) OR use backend-provided expiry
3. Replace Option B with accurate expiry-based refresh

**Estimated Time:** 
- Backend: 1 hour
- Frontend: 1 hour
- Testing: 1 hour
- Total: 3 hours

---

## 🎫 BACKEND TICKET

**Should we create a backend ticket?**

**YES** - For Phase 2 (long term solution)

**Ticket Details:**

**Title:** Add Token Expiry Information to Auth Responses

**Priority:** P2 (Medium - UX improvement)

**Description:**
Currently, auth endpoints return tokens without expiry information, forcing frontend to either:
1. Parse JWT (adds dependency)
2. Use fixed intervals (inefficient)
3. Wait for 401 (poor UX)

**Request:**
Add `expires_in` and `refresh_expires_in` fields to all auth responses:
- `POST /api/v1/auth/login` (if used)
- `POST /api/v1/auth/otp/email/verify`
- `POST /api/v1/auth/otp/phone/verify`
- `POST /api/v1/auth/refresh`

**Response Format:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "expires_in": 900,           // NEW: seconds until access expires
    "refresh_expires_in": 604800, // NEW: seconds until refresh expires
    "admin": {...}
  }
}
```

**Benefits:**
- ✅ Frontend can refresh proactively (better UX)
- ✅ No JWT parsing needed
- ✅ More efficient (refresh only when needed)
- ✅ Industry standard (OAuth 2.0 spec)

---

## ✅ DECISION MATRIX

| Criteria | Option A (JWT) | Option B (Fixed) | Option C (Backend) |
|----------|---------------|-----------------|-------------------|
| **Speed to Implement** | 1 hour | 30 min | 3+ hours |
| **Accuracy** | High | Medium | Highest |
| **Dependencies** | jwt_decode | None | Backend change |
| **UX** | Excellent | Good | Excellent |
| **Maintainability** | Medium | Easy | Easy |
| **Production Ready** | Yes | Yes | Yes |
| **Recommendation** | Long term | **SHORT TERM** | **IDEAL** |

---

## 🚀 ACTION ITEMS

### TODAY:
1. ✅ **Implement Option B** (Fixed interval refresh)
   - Create TokenManager
   - Integrate with ApiClient
   - Test with 10-minute interval

2. ✅ **Document current state**
   - This document
   - Code comments

### NEXT SPRINT:
1. ⏳ **Create backend ticket** for Option C
2. ⏳ **Implement Option A or C** (based on backend response)
3. ⏳ **Remove Option B** workaround

---

## 📝 SUMMARY

**Current State:**
- ✅ Reactive refresh implemented (works on 401)
- ❌ No proactive refresh (waits for expiry)
- ❌ User sees delay when token expires

**Short Term Fix (TODAY):**
- ✅ Fixed interval refresh every 10 minutes
- ✅ No backend changes needed
- ✅ Immediate UX improvement

**Long Term Solution (NEXT SPRINT):**
- ✅ Backend returns expiry info
- ✅ Proactive refresh before expiry
- ✅ Perfect UX (no delays)

**Decision:**
→ Implement **Option B today** for immediate improvement  
→ Create **backend ticket** for Option C (ideal solution)  
→ Switch to **Option C next sprint** when backend ready

---

**Status:** ✅ PLAN READY - PROCEED WITH OPTION B  
**Next:** Implement TokenManager and integrate with ApiClient
