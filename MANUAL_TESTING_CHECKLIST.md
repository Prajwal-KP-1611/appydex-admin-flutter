# 🧪 Manual UI Testing Checklist - AppyDex Admin

**Date:** November 3, 2025  
**App URL:** http://localhost:9090  
**Backend URL:** http://localhost:16110  
**Status:** Ready for Testing

---

## 🎯 TESTING OVERVIEW

**Total Estimated Time:** 38 minutes  
**Critical Flows:** 7 sections  
**Test Scenarios:** 45+ test cases

**Browser:** Chrome (recommended)  
**Screen Sizes:** Test at 1920x1080 (desktop standard)

---

## ✅ PRE-TESTING SETUP

### 1. Backend Status
- [ ] Backend API is running at `http://localhost:16110`
- [ ] Database is accessible
- [ ] Test data is available (admins, vendors, services)

### 2. Browser Setup
- [ ] Open Chrome browser
- [ ] Navigate to `http://localhost:9090`
- [ ] Open DevTools (F12) - Console tab
- [ ] Check for any errors (should be none)

### 3. Test Credentials
```
Email: admin@appydex.com (or your test admin)
Password: [your test password]
```

---

## 🧪 TEST SECTION 1: AUTHENTICATION (5 min)

### Test 1.1: Login - Valid Credentials ✅
**Steps:**
1. Enter valid email
2. Enter valid password
3. Click "Login"

**Expected:**
- ✓ Shows loading indicator
- ✓ Redirects to dashboard
- ✓ Top bar shows user name
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 1.2: Login - Invalid Credentials ❌
**Steps:**
1. Enter invalid email
2. Enter wrong password
3. Click "Login"

**Expected:**
- ✓ Shows error message
- ✓ Stays on login page
- ✓ Error is user-friendly
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 1.3: Session Persistence 🔄
**Steps:**
1. Login successfully
2. Refresh page (F5)

**Expected:**
- ✓ Stays logged in
- ✓ Returns to same page
- ✓ No re-login required

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 1.4: Logout 🚪
**Steps:**
1. Click user menu (top right)
2. Click "Logout"

**Expected:**
- ✓ Redirects to login page
- ✓ Session cleared
- ✓ Can't access protected pages

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 2: ADMIN USERS MANAGEMENT (8 min)

### Test 2.1: List Admin Users 📋
**Steps:**
1. Login
2. Navigate to "Admin Users"

**Expected:**
- ✓ Shows list of admins
- ✓ Displays: Name, Email, Role, Status
- ✓ Pagination controls visible
- ✓ Search box available
- ✓ "Create Admin" button visible

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.2: Search Admin Users 🔍
**Steps:**
1. On Admin Users page
2. Type admin name in search box
3. Wait 500ms (debounce)

**Expected:**
- ✓ Shows loading indicator
- ✓ Filters results
- ✓ Shows matching admins only
- ✓ "No results" if not found

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.3: Filter by Role 🎭
**Steps:**
1. Click "Role" dropdown
2. Select "Super Admin"

**Expected:**
- ✓ Shows only super admins
- ✓ Table updates
- ✓ Count updates

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.4: Create New Admin ➕
**Steps:**
1. Click "Create Admin"
2. Fill form:
   - Name: "Test Admin"
   - Email: "test@admin.com"
   - Role: "Admin"
   - Password: "TestPass123!"
3. Click "Create"

**Expected:**
- ✓ Shows loading indicator
- ✓ Success toast appears
- ✓ Dialog closes
- ✓ New admin appears in list
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.5: Create Admin - Validation ⚠️
**Steps:**
1. Click "Create Admin"
2. Try to submit with:
   - Empty fields
   - Invalid email
   - Weak password

**Expected:**
- ✓ Shows validation errors
- ✓ Can't submit until valid
- ✓ Error messages are clear

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.6: Edit Admin User ✏️
**Steps:**
1. Click edit icon on an admin
2. Change name to "Updated Admin"
3. Click "Update"

**Expected:**
- ✓ Pre-fills current data
- ✓ Success toast appears
- ✓ List updates with new name
- ✓ Dialog closes

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.7: Toggle Admin Active Status 🔄
**Steps:**
1. Find active admin
2. Click toggle switch

**Expected:**
- ✓ Shows confirmation dialog
- ✓ Status changes immediately
- ✓ Success toast appears
- ✓ Badge color changes

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.8: Delete Admin User 🗑️
**Steps:**
1. Click delete icon on test admin
2. Confirm deletion

**Expected:**
- ✓ Shows confirmation dialog
- ✓ Admin removed from list
- ✓ Success toast appears
- ✓ Count updates

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 2.9: Pagination 📄
**Steps:**
1. If > 25 admins, test pagination
2. Click "Next Page"
3. Change page size to 50

**Expected:**
- ✓ Shows next 25 admins
- ✓ Page indicator updates
- ✓ Page size changes work
- ✓ Total count accurate

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 3: SERVICES MANAGEMENT (6 min)

### Test 3.1: List Services 📋
**Steps:**
1. Navigate to "Services"

**Expected:**
- ✓ Shows list of services
- ✓ Displays: Name, Category, Price, Visibility
- ✓ "Create Service" button visible
- ✓ Search and filters available

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 3.2: Create New Service ➕
**Steps:**
1. Click "Create Service"
2. Fill form:
   - Name: "Test Service"
   - Category: Select one
   - Description: "Test description"
   - Price: 1000
   - Visibility: Yes
3. Click "Create"

**Expected:**
- ✓ Form validates
- ✓ Success toast appears
- ✓ Service appears in list
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 3.3: Edit Service ✏️
**Steps:**
1. Click edit on a service
2. Change name to "Updated Service"
3. Click "Update"

**Expected:**
- ✓ Pre-fills data
- ✓ Updates successfully
- ✓ List refreshes

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 3.4: Toggle Visibility 👁️
**Steps:**
1. Toggle service visibility switch

**Expected:**
- ✓ Status changes
- ✓ Badge updates
- ✓ Success toast

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 3.5: Delete Service 🗑️
**Steps:**
1. Click delete on test service
2. Confirm deletion

**Expected:**
- ✓ Confirmation dialog
- ✓ Service removed
- ✓ Success toast

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 3.6: Filter by Category 🏷️
**Steps:**
1. Select category from dropdown
2. Observe filtered results

**Expected:**
- ✓ Shows only services in category
- ✓ Count updates
- ✓ Clear filter works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 4: VENDOR APPROVAL WORKFLOW (12 min) ⭐ CRITICAL

### Test 4.1: List Vendors 📋
**Steps:**
1. Navigate to "Vendors"

**Expected:**
- ✓ Shows vendor list
- ✓ Displays: Name, Email, Status, Plan
- ✓ Status badges (Verified/Pending)
- ✓ Filter controls visible

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.2: Filter by Verification Status 🔍
**Steps:**
1. Select "Pending" from status filter
2. Observe results

**Expected:**
- ✓ Shows only unverified vendors
- ✓ List updates
- ✓ Count accurate

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.3: View Vendor Details 👁️
**Steps:**
1. Click on a vendor name/row
2. View detail page

**Expected:**
- ✓ Shows vendor profile
- ✓ Business information displayed
- ✓ Contact details visible
- ✓ Onboarding score shown
- ✓ Action buttons visible (Approve/Reject/Documents)

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.4: View KYC Documents 📄 ⭐
**Steps:**
1. On vendor detail page
2. Click "View Documents" button
3. Click on a document

**Expected:**
- ✓ Dialog opens with document list
- ✓ Shows document types, dates, status
- ✓ Icons indicate document type
- ✓ Status chips show verification state
- ✓ Can view document full-screen
- ✓ Close button works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.5: Approve Vendor ✅ ⭐
**Steps:**
1. On vendor detail page (unverified vendor)
2. Click "Approve" button
3. Add notes: "All documents verified"
4. Click "Approve" in dialog

**Expected:**
- ✓ Approval dialog opens
- ✓ Notes field optional
- ✓ Shows loading indicator
- ✓ Success toast appears: "Vendor approved successfully"
- ✓ Status updates to "Verified"
- ✓ Badge turns green
- ✓ Action buttons update
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.6: Reject Vendor ❌ ⭐
**Steps:**
1. On vendor detail page (unverified vendor)
2. Click "Reject" button
3. Enter reason: "Incomplete documentation"
4. Click "Reject" in dialog

**Expected:**
- ✓ Rejection dialog opens
- ✓ Reason field REQUIRED
- ✓ Can't submit without reason
- ✓ Shows loading indicator
- ✓ Success toast appears: "Vendor rejected"
- ✓ Status updates
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.7: Approve Without Notes 📝
**Steps:**
1. Click "Approve" on vendor
2. Leave notes empty
3. Click "Approve"

**Expected:**
- ✓ Accepts empty notes (optional)
- ✓ Approves successfully
- ✓ Success toast shown

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.8: Reject Without Reason ⚠️
**Steps:**
1. Click "Reject" on vendor
2. Leave reason empty
3. Try to click "Reject"

**Expected:**
- ✓ Shows validation error
- ✓ Button disabled or error shown
- ✓ Can't submit without reason

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.9: Bulk Approve Vendors 🔢 ⭐
**Steps:**
1. On vendors list page
2. Select 2-3 unverified vendors (checkboxes)
3. Click "Bulk Approve" button
4. Add notes (optional)
5. Confirm

**Expected:**
- ✓ Checkboxes work
- ✓ Bulk approve button enabled when > 0 selected
- ✓ Shows count of selected vendors
- ✓ Confirmation dialog shows count
- ✓ Success toast shows count: "3 vendors approved"
- ✓ All selected vendors update to verified
- ✓ Checkboxes clear
- ✓ No console errors

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 4.10: Cancel Approval Dialog 🚫
**Steps:**
1. Click "Approve" on vendor
2. Click "Cancel" in dialog

**Expected:**
- ✓ Dialog closes
- ✓ No changes made
- ✓ Vendor status unchanged

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 5: AUDIT LOGS (3 min)

### Test 5.1: View Audit Logs 📋
**Steps:**
1. Navigate to "Audit Logs"

**Expected:**
- ✓ Shows list of events
- ✓ Displays: Action, Admin, Time, Subject
- ✓ Most recent events first
- ✓ Pagination works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 5.2: Filter by Action Type 🔍
**Steps:**
1. Select action type (e.g., "vendor.verify")
2. Apply filter

**Expected:**
- ✓ Shows only matching actions
- ✓ Count updates
- ✓ Clear filter works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 5.3: Filter by Date Range 📅
**Steps:**
1. Select date range
2. Apply filter

**Expected:**
- ✓ Shows events in range
- ✓ Correctly filters
- ✓ No events outside range

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 5.4: Verify Logged Actions 🔎
**Steps:**
1. Approve a vendor
2. Go to Audit Logs
3. Look for the approval event

**Expected:**
- ✓ Event appears in logs
- ✓ Shows correct action
- ✓ Shows correct admin
- ✓ Shows correct timestamp

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 6: ERROR HANDLING (2 min)

### Test 6.1: Network Error Handling 🌐
**Steps:**
1. Disconnect network (or stop backend)
2. Try any action (e.g., load vendors)

**Expected:**
- ✓ Shows user-friendly error
- ✓ No crash
- ✓ Can retry
- ✓ Console shows error (expected)

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 6.2: Invalid Form Data ⚠️
**Steps:**
1. Try to create admin with:
   - Invalid email format
   - Short password
   - Empty required fields

**Expected:**
- ✓ Shows validation errors
- ✓ Prevents submission
- ✓ Error messages clear

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 6.3: API Error Responses ❌
**Steps:**
1. Try to create duplicate admin
2. Or perform unauthorized action

**Expected:**
- ✓ Shows API error message
- ✓ Error is user-friendly
- ✓ Toast notification appears
- ✓ No console crash

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 🧪 TEST SECTION 7: UI/UX QUALITY (2 min)

### Test 7.1: Responsive Layout 📱
**Steps:**
1. Resize browser window
2. Test at different widths

**Expected:**
- ✓ Layout adjusts
- ✓ No horizontal scroll
- ✓ All elements visible
- ✓ Mobile drawer works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 7.2: Loading States ⏳
**Steps:**
1. Observe loading indicators during:
   - Login
   - List loading
   - Form submission
   - Approval actions

**Expected:**
- ✓ Shows loading spinner/skeleton
- ✓ Prevents duplicate clicks
- ✓ Clears after completion

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 7.3: Empty States 📭
**Steps:**
1. View list with no data
2. Apply filter with no results

**Expected:**
- ✓ Shows "No data" message
- ✓ Has helpful icon/illustration
- ✓ Suggests action (e.g., "Create first admin")

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 7.4: Toast Notifications 🔔
**Steps:**
1. Perform any action
2. Check for feedback

**Expected:**
- ✓ Success actions show green toast
- ✓ Errors show red toast
- ✓ Toasts auto-dismiss
- ✓ Messages are clear

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

### Test 7.5: Navigation 🧭
**Steps:**
1. Test sidebar navigation
2. Use breadcrumbs
3. Use browser back button

**Expected:**
- ✓ All links work
- ✓ Active page highlighted
- ✓ Breadcrumbs accurate
- ✓ Back button works

**Result:** [ ] PASS [ ] FAIL  
**Notes:** _________________

---

## 📊 TEST RESULTS SUMMARY

### Completion Status
```
Section 1 - Authentication:      ___ / 4 tests passing
Section 2 - Admin Users:         ___ / 9 tests passing
Section 3 - Services:            ___ / 6 tests passing
Section 4 - Vendor Approval:     ___ / 10 tests passing ⭐
Section 5 - Audit Logs:          ___ / 4 tests passing
Section 6 - Error Handling:      ___ / 3 tests passing
Section 7 - UI/UX:               ___ / 5 tests passing

TOTAL:                           ___ / 41 tests passing
```

### Critical Flows (Must Pass)
- [ ] Login/Logout
- [ ] Create Admin
- [ ] Create Service
- [ ] **Approve Vendor** ⭐
- [ ] **Reject Vendor** ⭐
- [ ] **View Documents** ⭐
- [ ] **Bulk Approve** ⭐

### Overall Assessment
```
[ ] PASS - Ready for production
[ ] FAIL - Issues found (document below)

Issues Found:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________
```

---

## 🐛 BUG REPORT TEMPLATE

**Bug #:** ___  
**Section:** _______________  
**Test Case:** _______________  
**Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low

**Steps to Reproduce:**
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

**Expected Result:** _______________________________________________

**Actual Result:** _______________________________________________

**Screenshot/Console Error:** _______________________________________________

---

## ✅ SIGN-OFF

**Tester:** _______________________  
**Date:** _______________________  
**Time Spent:** _______ minutes  
**Result:** [ ] APPROVED [ ] NEEDS FIXES

**Notes:**
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________

---

**Generated:** November 3, 2025  
**App Version:** 1.0.0  
**Environment:** Development (localhost:9090)  
**Backend:** localhost:16110
