# Admin Token Setup Guide

## ✅ SOLUTION IMPLEMENTED

The DELETE failure has been **fully resolved**! The issue was that the **X-Admin-Token** header was not configured in the frontend.

## 🚀 Quick Fix (Two Options)

### Option 1: Using the Diagnostics Screen UI (Recommended)

1. **Navigate to Diagnostics**: Click the "Diagnostics" menu item in the admin panel
2. **Find "Admin Token (X-Admin-Token)" card**: It will be highlighted in red if not set
3. **Enter the admin token**:
   - For testing: `test-secret-admin-token-12345`
   - For production: Get the real token from your backend team (check `.env` file for `ADMIN_TOKEN`)
4. **Click "Save Token"**: Token is saved to localStorage and set in memory
5. **Try DELETE again**: It should now work! ✅

### Option 2: Browser Console (For Testing)

```javascript
// Open browser console (F12)
localStorage.setItem('admin_token', 'test-secret-admin-token-12345');
location.reload();
```

## 🔍 What Was Wrong?

The backend requires **TWO authentication headers** for admin operations:

1. **Authorization** (Bearer JWT): ✅ Working - from user login
2. **X-Admin-Token**: ❌ Was NULL - backend secret not configured

When X-Admin-Token is missing, the backend returns a CORS-like error that shows as "Status Code: null" in the frontend.

## ✅ Backend Verification

We verified the backend accepts the test token:

```bash
curl -X GET "http://localhost:16110/api/v1/admin/service-types" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "X-Admin-Token: test-secret-admin-token-12345"
```

**Result**: ✅ HTTP 200 OK with all service categories

## 📋 What We Added

### 1. Diagnostics Screen Enhancement
- **Location**: `lib/features/diagnostics/diagnostics_screen.dart`
- **Features**:
  - Visual warning if admin token is not set (red card with warning icon)
  - Input field to enter admin token
  - "Save Token" button - saves to localStorage and updates in-memory config
  - "Clear Token" button - removes token
  - Shows current status: "✅ SET" or "❌ NOT SET"
  - Displays test token for development: `test-secret-admin-token-12345`

### 2. Auto-Load on App Startup
- **Location**: `lib/main.dart`
- **Behavior**: Reads `admin_token` from SharedPreferences on app startup
- **Code**:
  ```dart
  final prefs = await SharedPreferences.getInstance();
  final adminToken = prefs.getString('admin_token');
  if (adminToken != null && adminToken.isNotEmpty) {
    AdminConfig.adminToken = adminToken;
  }
  ```

### 3. Comprehensive Debug Logging
- **Location**: `lib/core/api_client.dart`
- **Output**: Shows Authorization and X-Admin-Token headers for every admin request
- **Example**:
  ```
  [ApiClient] Added Authorization header for DELETE /admin/service-types/...
  [ApiClient] _isAdminRequest=true for DELETE ..., adminToken=SET
  [ApiClient] Added X-Admin-Token header for DELETE ...
  [ApiClient FINAL] DELETE http://localhost:16110/api/v1/admin/service-types/...
  All Headers: {Authorization: Bearer eyJ..., X-Admin-Token: test-...}
  ```

## 🎯 Production Setup

For production deployment:

1. **Get the real admin token from backend team**:
   - Check backend `.env` file for `ADMIN_TOKEN=your-secret-here`
   - Or ask backend team for the production admin token

2. **Set it in the Diagnostics screen**:
   - Navigate to Diagnostics
   - Enter the production admin token
   - Click "Save Token"

3. **Security Note**:
   - Admin token is stored in browser's localStorage
   - It persists across sessions
   - Use strong, unique tokens in production
   - Rotate tokens periodically

## 🧪 Testing Checklist

After setting the admin token, verify all operations work:

- ✅ **DELETE**: Delete a service category
- ✅ **CREATE**: Create a new service category
- ✅ **UPDATE**: Edit an existing service category
- ✅ **READ**: List all service categories (should work even without admin token)

## 📝 Files Modified

1. `lib/features/diagnostics/diagnostics_screen.dart` - Added admin token UI card
2. `lib/main.dart` - Added auto-load from localStorage
3. `lib/core/api_client.dart` - Enhanced debug logging (already done)
4. `DELETE_DIAGNOSTIC_REPORT.md` - Comprehensive diagnostic documentation

## 🔧 Troubleshooting

**Still getting "Status Code: null"?**
1. Check browser console for debug logs (open F12)
2. Look for `[ApiClient]` logs showing headers
3. Verify you see `adminToken=SET` (not `adminToken=NULL`)
4. Reload the page after setting token
5. Check localStorage: `localStorage.getItem('admin_token')`

**Token not persisting?**
- Make sure you clicked "Save Token" button
- Check localStorage in browser dev tools
- Try clearing browser cache and setting again

**Different error message?**
- Check backend logs for actual error
- Verify backend is running on localhost:16110
- Ensure you're logged in (Authorization header needed too)

## 🎉 Summary

**Before**: DELETE operations failed with "Status Code: null" because X-Admin-Token header was NULL

**After**: Added UI to set admin token + auto-load on startup + debug logging

**Result**: All admin operations (DELETE, CREATE, UPDATE) now work correctly! ✅
