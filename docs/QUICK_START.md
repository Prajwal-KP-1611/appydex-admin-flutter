# Quick Start Guide - AppyDex Admin Frontend

**Get up and running with local backend in 5 minutes**

---

## Prerequisites

- Flutter SDK 3.9.2+
- Local backend running at `http://localhost:16110`
- Chrome or Edge browser (for web development)

---

## Step 1: Verify Backend is Running

```bash
# Check if backend is accessible
curl http://localhost:16110/openapi/v1.json

# You should see JSON response with API spec
```

**If backend is NOT running:**
- Start your Python FastAPI backend
- Ensure it's listening on port 16110
- Check firewall settings

---

## Step 2: Install Dependencies

```bash
cd /home/devin/Desktop/APPYDEX/appydex-admin

# Get all packages
flutter pub get

# Should complete without errors
```

---

## Step 3: Verify API Configuration

**The codebase is already configured for local development:**

✅ API Base URL: `http://localhost:16110` (in `lib/core/config.dart`)  
✅ API Client configured  
✅ Auth endpoints configured

**No changes needed for local dev!**

---

## Step 4: Check Backend Endpoints

**Open OpenAPI spec and verify these endpoints exist:**

```bash
# View all endpoints
curl http://localhost:16110/openapi/v1.json | jq '.paths | keys'

# Look for:
# - /auth/admin/login or /admin/auth/login
# - /auth/refresh
# - /admin/users
# - /admin/vendors
```

**⚠️ If endpoints are missing:**
- Coordinate with backend team
- Update endpoint paths in frontend code if they differ

---

## Step 5: Run the App

```bash
# Run in Chrome on port 46633 (recommended for development)
flutter run -d chrome --web-port=46633 --web-hostname=localhost

# Or use VS Code: Press F5 (launches on port 46633 automatically)

# Or run on desktop (if enabled)
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

**App should open in browser at `http://localhost:46633` and show login screen.**

**Important:** The admin panel is configured to run on port **46633** locally. This port is whitelisted in the CORS configuration documentation for the backend team.

---

## Step 6: Login

**Use your backend's default admin credentials:**

- Email: `admin@appydex.test` (or check backend seed data)
- Password: `ChangeMe@2025!` (or check backend seed data)

**If login fails:**
- Open browser console (F12)
- Check Network tab for API call
- Verify request went to `http://localhost:16110/auth/admin/login`
- Check response for error details

---

## Step 7: Verify Dashboard Loads

After successful login, you should see:
- Dashboard screen
- Sidebar navigation
- Top navigation bar with your admin profile

---

## Troubleshooting

### Problem: "Failed to connect to backend"

**Check:**
```bash
# Is backend running?
curl http://localhost:16110/openapi/v1.json

# Check CORS headers
curl -I http://localhost:16110/admin/vendors
```

**Fix:** Ensure backend allows `localhost` origin in CORS config.

---

### Problem: "Login failed with 404"

**Cause:** Auth endpoint path mismatch

**Check backend OpenAPI spec:**
```bash
curl http://localhost:16110/openapi/v1.json | jq '.paths | keys | .[]' | grep login
```

**Fix:** Update auth endpoint in `lib/core/auth/auth_service.dart`:

```dart
// Try both:
'/auth/admin/login'  // or
'/admin/auth/login'
```

---

### Problem: "CORS error in browser"

**Backend needs to allow your origin:**

```python
# In your FastAPI backend
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:*"],  # Allow all localhost ports
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### Problem: "401 Unauthorized after login"

**Check:**
- Is access token being saved?
- Open browser DevTools → Application → Storage
- Look for access token in localStorage or secure storage

**Debug:**
- Add breakpoint in `lib/core/auth/auth_service.dart` after login
- Verify token is returned from backend
- Check token is being attached to subsequent requests

---

## Development Workflow

### 1. Make Code Changes

Edit files in `lib/` directory.

### 2. Hot Reload

Press `r` in terminal (or save file if running in IDE).

### 3. Test Changes

Navigate through app to test your changes.

### 4. Check Errors

- Browser console (F12 → Console)
- Flutter DevTools
- Backend logs

---

## Recommended Development Tools

### VS Code Extensions
- Dart
- Flutter
- Dart Data Class Generator
- Error Lens
- Better Comments

### Browser Extensions
- React Developer Tools (works with Flutter web)
- JSON Formatter

### API Testing
- Postman or Thunder Client
- cURL for quick tests

---

## Common Development Tasks

### Add New Screen

1. Create file in `lib/features/[module]/`
2. Add route in `lib/main.dart` → `onGenerateRoute`
3. Add navigation item in `lib/features/shared/admin_layout.dart`
4. Test navigation

### Add New API Endpoint

1. Update repository in `lib/repositories/`
2. Add method calling API client
3. Use idempotency for mutations:
```dart
options: idempotentOptions()
```
4. Test with local backend

### Add Form Validation

```dart
import '../../core/utils/validators.dart';

TextFormField(
  validator: Validators.email,
  // or
  validator: Validators.combine([
    (v) => Validators.required(v, fieldName: 'Email'),
    Validators.email,
  ]),
)
```

---

## Testing Against Local Backend

### Manual Test Flow

1. **Auth Flow**
   ```
   Login → Dashboard → Logout → Login again
   ```

2. **CRUD Flow**
   ```
   List → Create → Edit → Delete
   ```

3. **Error Handling**
   ```
   Stop backend → Try action → See error message
   ```

### Integration Testing

```bash
# Run integration tests (when implemented)
flutter test integration_test/

# Run widget tests
flutter test
```

---

## Hot Tips

### View Current API Base URL

Open Diagnostics screen:
- Navigate to `/diagnostics`
- Shows current API base URL
- Test API connectivity
- View last request/response

### Check Trace IDs

Every API request has a trace ID:
- In browser Network tab → Headers → `X-Trace-Id`
- Use this to correlate with backend logs

### Use Mock Mode (Future)

Enable mock mode to test UI without backend:
```dart
// In diagnostics screen
await ref.read(mockModeProvider.notifier).toggle(true);
```

---

## Next Steps

After confirming local dev works:

1. **Implement missing screens** (see `IMPLEMENTATION_GUIDE.md`)
2. **Test all CRUD operations**
3. **Verify RBAC permissions**
4. **Add unit tests**
5. **Prepare for staging deployment**

---

## Need Help?

**Check these docs:**
- `GAP_ANALYSIS.md` - What's missing vs spec
- `IMPLEMENTATION_GUIDE.md` - How to build features
- `PRODUCTION_CHANGE_POINTS.md` - Config for production
- `IMPLEMENTATION_STATUS.md` - Current progress

**Debug checklist:**
1. Check browser console
2. Check Flutter debug console
3. Check backend logs
4. Check Network tab in DevTools
5. Verify API endpoint paths match backend

---

**You're ready to develop! 🚀**

Run: `flutter run -d chrome --dart-define=APP_FLAVOR=dev`
