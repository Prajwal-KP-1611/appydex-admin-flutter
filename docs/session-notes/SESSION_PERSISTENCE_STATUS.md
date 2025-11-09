# Session Persistence Status

## ✅ Completed Features

### 1. JWT-Only Authentication
- Migrated from X-Admin-Token to JWT Bearer tokens
- All API requests use `Authorization: Bearer <token>` header
- Tests passing: 29/29

### 2. Session Persistence Across Reloads
- **Web**: Uses `SharedPreferences` (localStorage)
- **Mobile/Desktop**: Uses `FlutterSecureStorage`
- Session includes: access token, refresh token, email, roles, active role
- Email hydration: Falls back to typed email on login and last saved email on restore

### 3. Email Display Fix
- Bottom-left sidebar now shows correct email and role
- Email is hydrated from `/admin/me` when missing
- Fallback chain: backend response → /admin/me → typed email → last saved email

### 4. RBAC Fixes
- Super Admin access grants if ANY role includes `super_admin` (not just active role)
- Default active role selection prefers `super_admin` when `active_role` missing
- Admin Users screen properly grants access to Super Admins

### 5. UI Enhancements
- Added logout button to sidebar
- User info display (email + active role)
- Service Type Requests exposed in sidebar and routes
- Navigation logging for debugging

### 6. Route Persistence Infrastructure
- `AppRouteObserver`: Tracks and persists last visited route
- `LastRoute`: Helper to read/write last route path
- Routes are saved to `SharedPreferences` on navigation

## ⚠️ Known Limitation

**Initial Route After Reload**: Currently defaults to `/dashboard` instead of last visited page.

**Why**: The `initialRoute` in MaterialApp is evaluated before session restoration completes, so we can't reliably determine authentication status at that moment. Attempting a reactive AuthGate widget caused infinite rebuild loops.

**Workaround Options**:
1. Accept dashboard as default (simple, stable)
2. Add a splash screen that waits for session init, then navigates (more complex)
3. Use browser back button to return to last page (browser history is preserved)

## 🧪 Test Results

All tests passing:
```
00:06 +29: All tests passed!
```

## 📝 Files Modified

### Core Auth
- `lib/core/auth/auth_service.dart`: Email fallbacks, web persistence helpers
- `lib/core/auth/token_storage.dart`: Web/mobile storage abstraction
- `lib/models/admin_role.dart`: Role parsing and session serialization

### Navigation
- `lib/main.dart`: Route setup and auth guards
- `lib/core/navigation/app_route_observer.dart`: Route persistence observer
- `lib/core/navigation/last_route.dart`: Last route storage helper

### UI
- `lib/features/shared/admin_sidebar.dart`: Logout button, user info, Service Type Requests menu
- `lib/features/admins/admins_list_screen.dart`: Fixed RBAC check for Super Admins
- `lib/features/auth/login_screen.dart`: Duplicate submission guard

### Features
- `lib/features/service_type_requests/requests_list_screen.dart`: Exposed in routing
- `lib/repositories/service_type_requests_repository.dart`: Approve/reject endpoints

## 🚀 Deployment Readiness

✅ Build: Clean compile
✅ Tests: 29/29 passing
✅ Session: Persists across reloads
✅ Auth: JWT Bearer only
✅ RBAC: Super Admin access working
✅ UI: Logout and user info visible

**Ready for deployment** with the caveat that initial route defaults to dashboard.

## 🔧 Next Steps (Optional)

1. Add a debug flag to quiet verbose logging in production
2. Implement splash screen for smoother auth-aware initial routing
3. Add unit test for session restore with missing email
4. Consider decoding JWT client-side as final email fallback
