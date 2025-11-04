# Developer Action Checklist

**Start here! Complete these actions in order.**

---

## ✅ TODAY - Immediate Setup (15 minutes)

### 1. Verify Backend is Running

```bash
# Test backend connectivity
curl http://localhost:16110/openapi/v1.json

# Expected: JSON response with API spec
# If fails: Start your backend server
```

**Status:** [ ]

---

### 2. Check Backend Endpoints

```bash
# List all available endpoints
curl http://localhost:16110/openapi/v1.json | jq '.paths | keys | .[]'

# Look for these critical paths:
# - /auth/admin/login (or /admin/auth/login)
# - /auth/refresh
# - /admin/users
# - /admin/vendors
```

**Write down the auth login endpoint you found:**
```
My backend uses: ________________
```

**If it's NOT `/auth/admin/login`, you'll need to update `lib/core/auth/auth_service.dart`**

**Status:** [ ]

---

### 3. Install Flutter Dependencies

```bash
cd /home/devin/Desktop/APPYDEX/appydex-admin

flutter pub get
```

**Expected:** All packages install successfully

**Status:** [ ]

---

### 4. Run the Application

```bash
flutter run -d chrome --dart-define=APP_FLAVOR=dev
```

**Expected:** App opens in Chrome, shows login screen

**Status:** [ ]

---

### 5. Test Login Flow

**Use your backend's default admin credentials:**

- Email: `____________` (check your backend seed data)
- Password: `____________` (check your backend seed data)

**Expected:** Login succeeds, dashboard loads

**If login fails:**
- Open Chrome DevTools (F12)
- Go to Network tab
- Look for the login request
- Check request URL and response

**Status:** [ ]

---

### 6. Verify Dashboard Loads

**After login, you should see:**
- [ ] Dashboard screen
- [ ] Sidebar with navigation items
- [ ] Top bar with profile menu
- [ ] No error messages

**Status:** [ ]

---

## 🔧 TODAY - Configuration Check (10 minutes)

### 7. Verify API Configuration

**File:** `lib/core/config.dart`

**Check line ~6:**
```dart
const kDefaultApiBaseUrl = 'http://localhost:16110';
```

**Is this correct for your backend?**
- [ ] Yes, my backend runs on port 16110
- [ ] No, my backend runs on port: ______

**If different, update the port number.**

**Status:** [ ]

---

### 8. Check Auth Endpoint Path

**If your backend uses a different auth endpoint:**

**File:** `lib/core/auth/auth_service.dart`  
**Line:** ~52

```dart
final response = await _apiClient.dio.post<Map<String, dynamic>>(
  '/auth/admin/login',  // <-- Update this if needed
  data: {'email': email, 'password': password},
  options: Options(extra: const {'skipAuth': true}),
);
```

**My backend uses:** `________________`

**Status:** [ ]

---

### 9. Test Full Auth Flow

**Test these in order:**
1. [ ] Logout (click profile → logout)
2. [ ] Login again
3. [ ] Navigate to Vendors page
4. [ ] Navigate back to Dashboard
5. [ ] Refresh browser page (should stay logged in)

**Status:** [ ]

---

## 📝 THIS WEEK - Core Implementation (Phase A)

### 10. Review Documentation

Read these documents in order:
1. [ ] `QUICK_START.md` - Quick setup guide
2. [ ] `IMPLEMENTATION_SUMMARY.md` - High-level overview
3. [ ] `GAP_ANALYSIS.md` - Detailed gaps vs spec
4. [ ] `IMPLEMENTATION_GUIDE.md` - How to implement features

**Status:** [ ]

---

### 11. Understand the Codebase Structure

**Explore these key files:**
- [ ] `lib/main.dart` - App entry point and routing
- [ ] `lib/core/api_client.dart` - HTTP client with interceptors
- [ ] `lib/core/auth/auth_service.dart` - Authentication logic
- [ ] `lib/models/admin_role.dart` - RBAC model
- [ ] `lib/features/vendors/vendors_list_screen.dart` - Example list screen
- [ ] `lib/repositories/vendor_repo.dart` - Example repository

**Status:** [ ]

---

### 12. Set Up Your Development Environment

**Recommended VS Code Extensions:**
- [ ] Dart (dart-code.dart-code)
- [ ] Flutter (dart-code.flutter)
- [ ] Error Lens (usernamehw.errorlens)

**Enable Flutter DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Status:** [ ]

---

### 13. Create Your First Feature Branch

```bash
git checkout -b feature/admin-users-crud

# Make changes...
# Test locally
# Commit and push
```

**Status:** [ ]

---

### 14. Implement Admin Users CRUD Screen

**Priority:** HIGHEST (Phase A deliverable)

**File to create:** `lib/features/admins/admins_list_screen.dart`

**Reference implementation:** Study `lib/features/vendors/vendors_list_screen.dart`

**Key requirements:**
- [ ] DataTable with pagination
- [ ] Search by email/name
- [ ] Filter by role and status
- [ ] Create admin dialog
- [ ] Edit admin dialog
- [ ] Delete confirmation
- [ ] Toggle active/inactive
- [ ] Use `AdminUserRepository` from `lib/repositories/admin_user_repo.dart`

**Status:** [ ]

---

### 15. Add Admin Management Route

**File:** `lib/main.dart`

**Add in `onGenerateRoute` switch:**
```dart
case '/admins':
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => const AdminsListScreen(),
  );
```

**Import the screen:**
```dart
import 'features/admins/admins_list_screen.dart';
```

**Status:** [ ]

---

### 16. Test Admin CRUD Operations

**Test flow:**
1. [ ] Navigate to /admins route
2. [ ] List loads existing admins
3. [ ] Click "Create Admin" button
4. [ ] Fill form and submit (watch network tab)
5. [ ] Verify admin appears in list
6. [ ] Edit the admin
7. [ ] Delete the admin
8. [ ] Check all mutations use `Idempotency-Key` header

**Status:** [ ]

---

## 🚀 NEXT STEPS - Continue Phase A

### 17. Implement Services CRUD

**File:** `lib/features/services/services_list_screen.dart`

**Status:** [ ]

---

### 18. Complete Vendor Approval Workflow

**File:** `lib/features/vendors/vendor_detail_screen.dart` (UPDATE)

**Add:**
- [ ] Approve button with idempotency
- [ ] Reject button
- [ ] Document viewer modal
- [ ] Bulk approve (in list screen)

**Status:** [ ]

---

### 19. Implement Forced Password Change Flow

**Update login flow to check `must_change_password` flag:**

**File:** `lib/core/auth/auth_service.dart`

**After successful login, check session:**
```dart
if (session.mustChangePassword) {
  // Navigate to /change-password instead of /dashboard
}
```

**Status:** [ ]

---

### 20. Write Unit Tests

**Start with:**
- [ ] Test auth service login/logout
- [ ] Test RBAC permission checks
- [ ] Test idempotency key generation
- [ ] Test admin user model serialization

**Run tests:**
```bash
flutter test
```

**Status:** [ ]

---

## 📊 TRACKING YOUR PROGRESS

### Daily Checklist

**End of each day, mark what you completed:**

**Day 1:**
- [ ] Backend verified
- [ ] App running locally
- [ ] Login working
- [ ] Reviewed documentation

**Day 2:**
- [ ] Admin users repository tested
- [ ] Started admin CRUD screen
- [ ] Created feature branch

**Day 3:**
- [ ] Admin CRUD screen complete
- [ ] Tested against backend
- [ ] Unit tests written

**Day 4:**
- [ ] Services CRUD started
- [ ] Vendor approval workflow updated
- [ ] Integration tested

**Day 5:**
- [ ] Phase A features complete
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Ready for merge

---

## 🐛 Troubleshooting Quick Reference

### Problem: Can't connect to backend
**Check:**
```bash
curl http://localhost:16110/openapi/v1.json
netstat -an | grep 16110
```

---

### Problem: CORS errors in browser
**Fix:** Backend CORS config must allow `http://localhost:*`

---

### Problem: Login returns 404
**Fix:** Check auth endpoint path matches backend

---

### Problem: Token not persisting
**Check:** Browser DevTools → Application → Storage

---

### Problem: Idempotency-Key not sent
**Fix:** Use `idempotentOptions()` from `lib/core/utils/idempotency.dart`

---

## 📞 Need Help?

**Quick answers:**
1. Backend issues → Check backend logs
2. CORS issues → Check backend CORS config
3. Auth issues → Check Network tab in DevTools
4. Implementation questions → See `IMPLEMENTATION_GUIDE.md`
5. Production config → See `PRODUCTION_CHANGE_POINTS.md`

---

## ✨ Success Criteria for Week 1

By end of Week 1, you should have:
- [x] App running locally
- [x] Login working
- [ ] Admin users CRUD complete
- [ ] Services CRUD complete
- [ ] Vendor approval workflow complete
- [ ] All mutations using idempotency
- [ ] Unit tests passing
- [ ] Phase A deliverable ready

---

## 🎯 What Good Looks Like

**After completing this checklist:**
- ✅ You can run the app locally
- ✅ You can login as admin
- ✅ You can create/edit/delete admin users
- ✅ You can approve vendors
- ✅ You can manage services
- ✅ All API calls have trace IDs
- ✅ All mutations use idempotency
- ✅ No console errors
- ✅ Tests pass

---

## 📅 Timeline Expectations

**Week 1:** Complete this checklist + Phase A features  
**Week 2:** Phase B (Billing & Subscriptions)  
**Week 3:** Phase C & D (Analytics & Dashboard)  
**Week 4:** Phase E (Desktop & Offline)  
**Week 5-6:** Phase F (Production prep)

---

**Start with item #1 and work through sequentially. Don't skip ahead!**

**Good luck! 🚀**
