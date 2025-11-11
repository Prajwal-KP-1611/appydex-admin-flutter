# Feedback System Testing Guide

**Date:** November 11, 2025  
**Status:** Backend Endpoints Implemented ✅

This guide walks you through testing the complete feedback system with the live backend.

---

## Prerequisites

- ✅ Backend running on `http://localhost:16110`
- ✅ Admin panel running on `http://localhost:61101`
- ✅ Valid admin JWT token (logged in)
- ✅ Backend feedback endpoints deployed

---

## Test Scenarios

### 1. Navigation Test

**Objective:** Verify feedback menu is accessible

**Steps:**
1. Log in to admin panel
2. Look for "Feedback" in left sidebar under "ENGAGEMENT" section
3. Click on "Feedback"

**Expected Result:**
- ✅ Navigates to `/feedback` route
- ✅ Shows feedback list screen
- ✅ Displays stats banner at top

---

### 2. Stats Dashboard Test

**Objective:** Verify dashboard metrics load correctly

**Steps:**
1. Navigate to feedback list screen
2. Observe stats banner at top

**Expected Result:**
- ✅ Shows "Total Feedback" count
- ✅ Shows "Pending Review" count
- ✅ Shows "Response Rate" percentage
- ✅ Shows "Avg Response Time" in hours
- ✅ Stats load without errors

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/stats
Authorization: Bearer <jwt_token>
```

**Sample Response:**
```json
{
  "total": 156,
  "pending_review": 12,
  "response_rate": 57.1,
  "avg_response_time_hours": 2.3,
  "by_status": {...},
  "by_priority": {...},
  "by_category": {...}
}
```

---

### 3. Feedback List Test

**Objective:** Verify feedback items display correctly

**Steps:**
1. Observe the data table below filters
2. Check all columns are visible
3. Verify data is populated

**Expected Result:**
- ✅ Table shows columns: ID, Title, Category, Status, Priority, Submitter, Votes, Comments, Visibility, Created, Actions
- ✅ Category chips are color-coded
- ✅ Status chips are color-coded
- ✅ Priority chips are color-coded (if set)
- ✅ Visibility shows lock/globe icon
- ✅ Actions column has arrow button

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/?page=1&page_size=50
Authorization: Bearer <jwt_token>
```

**Sample Response:**
```json
{
  "items": [
    {
      "id": 1,
      "title": "Add real-time notifications",
      "category": "feature_request",
      "status": "in_progress",
      "priority": "high",
      "submitter_name": "John Doe",
      "submitter_type": "user",
      "votes_count": 47,
      "comments_count": 12,
      "is_public": true,
      "created_at": "2025-11-01T10:15:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 50,
    "total": 156,
    "total_pages": 4
  }
}
```

---

### 4. Filter Test - Category

**Objective:** Verify category filter works

**Steps:**
1. Click "Category" dropdown
2. Select "Feature Request"
3. Observe table updates

**Expected Result:**
- ✅ Table shows only feature request items
- ✅ Page resets to 1
- ✅ Stats may update (if stats respect filters)

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/?category=feature_request&page=1&page_size=50
Authorization: Bearer <jwt_token>
```

---

### 5. Filter Test - Status

**Objective:** Verify status filter works

**Steps:**
1. Click "Status" dropdown
2. Select "Pending"
3. Observe table updates

**Expected Result:**
- ✅ Table shows only pending items
- ✅ All status chips show "Pending"
- ✅ Page resets to 1

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/?status=pending&page=1&page_size=50
Authorization: Bearer <jwt_token>
```

---

### 6. Filter Test - Priority

**Objective:** Verify priority filter works

**Steps:**
1. Click "Priority" dropdown
2. Select "High"
3. Observe table updates

**Expected Result:**
- ✅ Table shows only high priority items
- ✅ All priority chips show "High"
- ✅ Items without priority are excluded

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/?priority=high&page=1&page_size=50
Authorization: Bearer <jwt_token>
```

---

### 7. Filter Test - Combined

**Objective:** Verify multiple filters work together

**Steps:**
1. Select Category: "Bug Report"
2. Select Status: "Pending"
3. Select Priority: "Critical"
4. Observe table updates

**Expected Result:**
- ✅ Table shows only items matching ALL filters
- ✅ Results narrow down appropriately

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/?category=bug_report&status=pending&priority=critical&page=1&page_size=50
Authorization: Bearer <jwt_token>
```

---

### 8. Clear Filters Test

**Objective:** Verify clear filters button works

**Steps:**
1. Apply multiple filters (category, status, priority)
2. Click "Clear Filters" button
3. Observe all filters reset

**Expected Result:**
- ✅ All filter dropdowns reset to "All"
- ✅ Table shows all feedback again
- ✅ Page resets to 1

---

### 9. Pagination Test

**Objective:** Verify pagination works

**Steps:**
1. Note total pages in pagination footer
2. Click "Next" button (▶)
3. Observe page number changes
4. Click "Previous" button (◀)

**Expected Result:**
- ✅ Page 2 loads successfully
- ✅ Different items appear in table
- ✅ Pagination shows "Page 2 of X"
- ✅ Previous button navigates back to page 1
- ✅ Next button disabled on last page
- ✅ Previous button disabled on first page

**API Calls:**
```
GET http://localhost:16110/api/v1/admin/feedback/?page=2&page_size=50
GET http://localhost:16110/api/v1/admin/feedback/?page=1&page_size=50
```

---

### 10. Feedback Detail Navigation Test

**Objective:** Verify navigation to detail screen

**Steps:**
1. Click arrow button (→) in Actions column for any feedback
2. Observe navigation

**Expected Result:**
- ✅ Navigates to `/feedback/detail` with feedback ID
- ✅ Detail screen loads
- ✅ Feedback details display

---

### 11. Feedback Detail Load Test

**Objective:** Verify feedback detail loads correctly

**Steps:**
1. On detail screen, observe all sections load
2. Check feedback card, comments, and actions panel

**Expected Result:**
- ✅ Feedback title displays
- ✅ Category, status, priority chips show
- ✅ Description text visible
- ✅ Submitter info shows with avatar
- ✅ Votes and comments count display
- ✅ Admin response shows (if exists)
- ✅ Comments thread loads (if any)
- ✅ Admin actions panel displays

**API Call:**
```
GET http://localhost:16110/api/v1/admin/feedback/1
Authorization: Bearer <jwt_token>
```

**Sample Response:**
```json
{
  "id": 1,
  "title": "Add real-time notifications",
  "description": "Would love to receive instant notifications...",
  "category": "feature_request",
  "status": "in_progress",
  "priority": "high",
  "submitter_name": "John Doe",
  "submitter_type": "user",
  "submitter_id": 105,
  "votes_count": 47,
  "comments_count": 12,
  "admin_response": "Great suggestion! We're currently implementing...",
  "responded_at": "2025-11-10T14:30:00Z",
  "is_public": true,
  "created_at": "2025-11-01T10:15:00Z",
  "updated_at": "2025-11-10T14:30:00Z",
  "comments": [
    {
      "id": 1,
      "commenter_name": "John Doe",
      "commenter_type": "user",
      "is_admin": false,
      "content": "This would be super helpful!",
      "created_at": "2025-11-01T10:20:00Z"
    }
  ]
}
```

---

### 12. Status Update Test

**Objective:** Verify status can be updated

**Steps:**
1. On detail screen, click "Status" dropdown
2. Select a different status (e.g., "Under Review")
3. Observe update

**Expected Result:**
- ✅ Dropdown changes immediately
- ✅ Toast notification: "Status updated successfully"
- ✅ Status chip updates
- ✅ Updated timestamp changes

**API Call:**
```
PATCH http://localhost:16110/api/v1/admin/feedback/1/status
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "status": "under_review"
}
```

**Sample Response:**
```json
{
  "id": 1,
  "status": "under_review",
  "updated_at": "2025-11-11T16:30:00Z",
  "message": "Status updated successfully"
}
```

---

### 13. Priority Update Test

**Objective:** Verify priority can be updated

**Steps:**
1. On detail screen, click "Priority" dropdown
2. Select a different priority (e.g., "Critical")
3. Observe update

**Expected Result:**
- ✅ Dropdown changes immediately
- ✅ Toast notification: "Priority updated successfully"
- ✅ Priority chip updates with new color

**API Call:**
```
PATCH http://localhost:16110/api/v1/admin/feedback/1/priority
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "priority": "critical"
}
```

---

### 14. Visibility Toggle Test

**Objective:** Verify visibility can be toggled

**Steps:**
1. On detail screen, observe current visibility switch state
2. Toggle the "Public Visibility" switch
3. Observe update

**Expected Result:**
- ✅ Switch toggles immediately
- ✅ Toast notification: "Feedback is now public/private"
- ✅ Visibility icon updates (lock/globe)

**API Call:**
```
PATCH http://localhost:16110/api/v1/admin/feedback/1/visibility
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "is_public": false
}
```

---

### 15. Admin Response Submit Test

**Objective:** Verify admin can submit response

**Steps:**
1. Scroll to "Add Admin Response" card
2. Type response (min 10 characters): "Thank you for this feedback. We are investigating the issue and will provide an update soon."
3. Optionally select auto-set status
4. Click "Submit Response"

**Expected Result:**
- ✅ Button shows loading spinner
- ✅ Toast notification: "Response submitted successfully"
- ✅ Form clears after submission
- ✅ Admin response appears in feedback card (may need refresh)
- ✅ Status updates if auto-set was selected

**API Call:**
```
POST http://localhost:16110/api/v1/admin/feedback/1/respond
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "response": "Thank you for this feedback. We are investigating...",
  "auto_set_status": "in_progress"
}
```

---

### 16. Response Validation Test

**Objective:** Verify form validation works

**Steps:**
1. In response form, type only 5 characters: "Hello"
2. Click "Submit Response"

**Expected Result:**
- ✅ Error message: "Response must be at least 10 characters"
- ✅ Form does not submit
- ✅ No API call made

---

### 17. Back Navigation Test

**Objective:** Verify back button works

**Steps:**
1. On detail screen, click back button (← Back)
2. Observe navigation

**Expected Result:**
- ✅ Navigates back to feedback list
- ✅ List maintains previous filters and page
- ✅ Updated feedback reflects changes (if any were made)

---

### 18. Empty State Test

**Objective:** Verify empty state displays correctly

**Steps:**
1. Apply filters that return no results (e.g., Category: "Performance" if none exist)
2. Observe table area

**Expected Result:**
- ✅ Empty state message displays
- ✅ Icon shows (feedback icon)
- ✅ Text: "No feedback found"

---

### 19. Error Handling Test

**Objective:** Verify error states work

**Steps:**
1. Stop backend server temporarily
2. Try to refresh feedback list
3. Observe error state

**Expected Result:**
- ✅ Error icon displays
- ✅ Error message shows
- ✅ "Retry" button appears
- ✅ Clicking retry attempts to reload

**Alternative:** Check browser DevTools Network tab for 401/500 errors

---

### 20. Comments Display Test

**Objective:** Verify comments thread displays correctly

**Steps:**
1. Navigate to feedback with comments
2. Scroll to "Comments" section
3. Observe comment items

**Expected Result:**
- ✅ Comments count shows in header
- ✅ Each comment has avatar
- ✅ Commenter name displays
- ✅ Comment type shows (user/vendor/admin)
- ✅ Admin comments have "ADMIN" badge
- ✅ Admin comments have blue background
- ✅ Timestamp shows for each comment
- ✅ Comment content is readable

---

## Browser DevTools Checklist

Open browser DevTools (F12) and verify:

### Network Tab
- [ ] All API calls return 200 OK (or expected status)
- [ ] Authorization header present in all requests
- [ ] Request/response formats match API contract
- [ ] No CORS errors
- [ ] No 401/403 errors (authentication issues)

### Console Tab
- [ ] No JavaScript errors
- [ ] No compilation warnings
- [ ] Debug prints show expected flow (if enabled)

### Performance Tab
- [ ] Page loads in < 3 seconds
- [ ] No memory leaks
- [ ] Smooth scrolling and interactions

---

## API Endpoint Coverage

Verify all endpoints are working:

| Endpoint | Method | Test Scenario | Status |
|----------|--------|---------------|--------|
| `/admin/feedback/` | GET | List feedback | ⬜ |
| `/admin/feedback/stats` | GET | Dashboard stats | ⬜ |
| `/admin/feedback/{id}` | GET | Feedback details | ⬜ |
| `/admin/feedback/{id}/status` | PATCH | Update status | ⬜ |
| `/admin/feedback/{id}/priority` | PATCH | Set priority | ⬜ |
| `/admin/feedback/{id}/visibility` | PATCH | Toggle visibility | ⬜ |
| `/admin/feedback/{id}/respond` | POST | Add response | ⬜ |

---

## Known Issues / Notes

**Record any issues found during testing:**

1. _[Issue description]_
   - Steps to reproduce:
   - Expected:
   - Actual:

2. _[Issue description]_
   - Steps to reproduce:
   - Expected:
   - Actual:

---

## Test Results Summary

**Date Tested:** _______________  
**Tester Name:** _______________  
**Environment:** Dev / Staging / Production

**Overall Status:** ✅ Pass / ⚠️ Pass with Issues / ❌ Fail

**Test Scenarios Passed:** ____ / 20  
**Critical Issues Found:** ____  
**Minor Issues Found:** ____  

**Sign-off:** _______________

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Update status to "Ready for Production"
2. Notify team in Slack
3. Schedule production deployment
4. Prepare monitoring/alerts

### If Issues Found ⚠️
1. Document all issues in this guide
2. Create GitHub issues for each bug
3. Prioritize critical vs. minor issues
4. Fix and re-test
5. Update implementation status

---

**Happy Testing! 🚀**
