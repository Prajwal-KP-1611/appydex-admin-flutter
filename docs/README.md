# APPYDEX Admin Panel - Documentation Index

**Last Updated:** November 9, 2025

This directory contains comprehensive documentation for the APPYDEX Admin Panel Flutter application.

---

## 📁 Directory Structure

```
docs/
├── README.md                          # This file - navigation guide
├── api/                               # API integration documentation
├── backend/                           # Backend requirements and issues
├── config/                            # Configuration guides
├── deployment/                        # Deployment and production guides
├── features/                          # Feature-specific documentation
│   ├── users/                        # End-users management
│   └── vendors/                      # Vendor management
├── implementation/                    # Implementation tracking
└── testing/                          # Testing documentation
```

---

## 🚀 Quick Start

**New to the project?** Start here:
1. [`QUICK_START.md`](QUICK_START.md) - Get the app running locally
2. [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md) - Development workflow and best practices
3. [`config/ENV_INJECTION_GUIDE.md`](config/ENV_INJECTION_GUIDE.md) - Configure environment variables

### Running the Admin Panel

**Web (recommended for admin):**
```bash
flutter run -d chrome --web-port=46633 --web-hostname=localhost
```
The app will be available at `http://localhost:46633`

**VS Code:** Press F5 to launch with the configured web port (46633)

**Mobile/Desktop:**
```bash
flutter run
```

---

## 📚 Documentation by Category

### **API & Backend Integration**

#### API Alignment & Contracts
- [`api/ADMIN_API_QUICK_REFERENCE.md`](api/ADMIN_API_QUICK_REFERENCE.md) - Quick API endpoint reference
- [`api/API_CONTRACT_ALIGNMENT.md`](api/API_CONTRACT_ALIGNMENT.md) - Frontend-backend contract alignment
- [`api/API_ALIGNMENT_SUMMARY.md`](api/API_ALIGNMENT_SUMMARY.md) - Summary of alignment work
- [`api/SERVICES_QUICK_REFERENCE.md`](api/SERVICES_QUICK_REFERENCE.md) - Services API reference

#### Authentication & OTP
- [`api/ADMIN_OTP_QUICK_VALIDATION.md`](api/ADMIN_OTP_QUICK_VALIDATION.md) - OTP validation flow
- [`api/ADMIN_OTP_UNIFIED_VERIFICATION.md`](api/ADMIN_OTP_UNIFIED_VERIFICATION.md) - Unified OTP system
- [`api/ADMIN_TOKEN_SETUP.md`](api/ADMIN_TOKEN_SETUP.md) - JWT token configuration

#### Specific API Domains
- [`api/ADMIN_API_ALIGNMENT.md`](api/ADMIN_API_ALIGNMENT.md) - Admin endpoints alignment
- [`api/SERVICES_API_ALIGNMENT.md`](api/SERVICES_API_ALIGNMENT.md) - Services endpoints
- [`api/SERVICE_TYPE_API_ALIGNMENT.md`](api/SERVICE_TYPE_API_ALIGNMENT.md) - Service type endpoints
- [`api/API_ALIGNMENT_IMPLEMENTATION.md`](api/API_ALIGNMENT_IMPLEMENTATION.md) - Implementation details

---

### **Backend Requirements & Issues**

#### Active Issues
- [`backend-tickets/BACKEND_TICKET_CRITICAL_API_ERRORS.md`](backend-tickets/BACKEND_TICKET_CRITICAL_API_ERRORS.md) - 🔴 **CRITICAL** - Vendors & Users API Issues (Nov 9, 2025)

#### Vendor Management Requirements
- [`backend/BACKEND_VENDOR_MANAGEMENT_ENDPOINTS_REQUIRED.md`](backend/BACKEND_VENDOR_MANAGEMENT_ENDPOINTS_REQUIRED.md) - 🔥 **64 vendor endpoints specification** (687 lines, P0-P3 priority)
- [`backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md`](backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md) - ✅ **Backend team implementation status** (P0/P1 complete)

#### General Backend Docs
- [`backend/BACKEND_TODO.md`](backend/BACKEND_TODO.md) - Outstanding backend tasks
- [`backend/BACKEND_DATABASE_ISSUE.md`](backend/BACKEND_DATABASE_ISSUE.md) - Known database issues
- [`backend/BACKEND_API_ALIGNMENT_FIXES.md`](backend/BACKEND_API_ALIGNMENT_FIXES.md) - Applied fixes

---

### **Configuration**

- [`config/ENV_INJECTION_GUIDE.md`](config/ENV_INJECTION_GUIDE.md) - Environment variable setup
- [`config/CSP_CONFIGURATION.md`](config/CSP_CONFIGURATION.md) - Content Security Policy
- [`config/WEB_SECURITY_CONFIG.md`](config/WEB_SECURITY_CONFIG.md) - Web security configuration

---

### **Deployment & Production**

#### Deployment Guides
- [`deployment/DEPLOYMENT_GUIDE.md`](deployment/DEPLOYMENT_GUIDE.md) - Complete deployment process
- [`deployment/DEPLOYMENT_SECURITY.md`](deployment/DEPLOYMENT_SECURITY.md) - Security checklist
- [`deployment/READY_TO_DEPLOY.md`](deployment/READY_TO_DEPLOY.md) - Pre-deployment verification
- [`deployment/DEPLOYMENT_NEXT_STEPS.md`](../DEPLOYMENT_NEXT_STEPS.md) - Post-deployment tasks

#### Production Readiness
- [`deployment/PRODUCTION_READY_CHECKLIST.md`](deployment/PRODUCTION_READY_CHECKLIST.md) - ✅ Checklist
- [`deployment/PRODUCTION_READY_FINAL.md`](deployment/PRODUCTION_READY_FINAL.md) - Final verification
- [`deployment/PRODUCTION_READY_IMPLEMENTATION.md`](deployment/PRODUCTION_READY_IMPLEMENTATION.md) - Implementation status

#### Production Features & Fixes
- [`deployment/PRODUCTION_FEATURES_IMPLEMENTATION.md`](deployment/PRODUCTION_FEATURES_IMPLEMENTATION.md) - Feature status
- [`deployment/PRODUCTION_FIXES_COMPLETE.md`](deployment/PRODUCTION_FIXES_COMPLETE.md) - Applied fixes
- [`deployment/PRODUCTION_CHANGE_POINTS.md`](deployment/PRODUCTION_CHANGE_POINTS.md) - Change log
- [`deployment/PRODUCTION_BLOCKERS_RESOLVED.md`](deployment/PRODUCTION_BLOCKERS_RESOLVED.md) - Blocker resolution

---

### **Feature Documentation**

#### End-Users Management (Customers)
- [`features/end-user-management/END_USER_MANAGEMENT_PLAN.md`](features/end-user-management/END_USER_MANAGEMENT_PLAN.md) - Implementation plan
- [`features/end-user-management/BACKEND_RESPONSE_END_USER_MGMT.md`](features/end-user-management/BACKEND_RESPONSE_END_USER_MGMT.md) - Backend requirements
- [`features/users/USERS_IMPLEMENTATION_COMPLETE.md`](features/users/USERS_IMPLEMENTATION_COMPLETE.md) - ✅ **Complete** - Users CRUD implementation (Nov 9, 2025)

**End-User Features:**
- Complete CRUD operations
- User detail with 6 tabs (Profile, Activity, Bookings, Payments, Reviews, Disputes)
- Status management (suspend/delete)
- Activity tracking
- Payment history
- Bookings management
- Reviews & ratings
- Dispute resolution
- Mock data fallback (18 endpoints pending backend implementation)

#### Vendor Management
- [`features/vendor-management/VENDOR_MANAGEMENT_ALIGNMENT_COMPLETE.md`](features/vendor-management/VENDOR_MANAGEMENT_ALIGNMENT_COMPLETE.md) - Alignment complete
- [`features/vendors/VENDOR_MANAGEMENT_FRONTEND_STATUS.md`](features/vendors/VENDOR_MANAGEMENT_FRONTEND_STATUS.md) - 🚧 **30% Complete** - Frontend status
- [`backend/BACKEND_VENDOR_MANAGEMENT_ENDPOINTS_REQUIRED.md`](backend/BACKEND_VENDOR_MANAGEMENT_ENDPOINTS_REQUIRED.md) - Backend requirements (64 endpoints)
- [`backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md`](backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md) - ✅ Backend P0/P1 complete

**Vendor Features:**
- Applications approval/rejection
- Services management
- Bookings tracking
- Leads pipeline
- Revenue & payouts
- Analytics dashboard
- Document verification
- Status management (suspend/ban/reactivate)

---

### **Implementation Tracking**

#### Complete Implementations
- [`implementation/IMPLEMENTATION_COMPLETE_FINAL.md`](implementation/IMPLEMENTATION_COMPLETE_FINAL.md) - Final status
- [`implementation/IMPLEMENTATION_STATUS_COMPLETE.md`](implementation/IMPLEMENTATION_STATUS_COMPLETE.md) - Completion summary
- [`implementation/ALIGNMENT_COMPLETE.md`](implementation/ALIGNMENT_COMPLETE.md) - API alignment complete
- [`implementation/CRITICAL_BLOCKERS_COMPLETE.md`](implementation/CRITICAL_BLOCKERS_COMPLETE.md) - Blockers resolved

#### Phase Completions
- [`implementation/PHASE_1_COMPLETE.md`](implementation/PHASE_1_COMPLETE.md) - Phase 1
- [`implementation/PHASE_A_ADMIN_CRUD_COMPLETE.md`](implementation/PHASE_A_ADMIN_CRUD_COMPLETE.md) - Admin CRUD
- [`implementation/PHASE_A_SERVICES_CRUD_COMPLETE.md`](implementation/PHASE_A_SERVICES_CRUD_COMPLETE.md) - Services CRUD

#### Progress Tracking
- [`implementation/IMPLEMENTATION_STATUS.md`](implementation/IMPLEMENTATION_STATUS.md) - Current status
- [`implementation/IMPLEMENTATION_SUMMARY.md`](implementation/IMPLEMENTATION_SUMMARY.md) - Summary
- [`implementation/IMPLEMENTATION_SUMMARY_NOV_8_2025.md`](implementation/IMPLEMENTATION_SUMMARY_NOV_8_2025.md) - Nov 8 snapshot
- [`implementation/IMPLEMENTATION_PROGRESS_SESSION.md`](implementation/IMPLEMENTATION_PROGRESS_SESSION.md) - Session notes
- [`implementation/README_IMPLEMENTATION.md`](implementation/README_IMPLEMENTATION.md) - Implementation guide

#### Session Records
- [`implementation/SESSION_AND_AUTH_FIXES.md`](implementation/SESSION_AND_AUTH_FIXES.md) - Auth fixes
- [`implementation/SESSION_COMPLETE_2025_11_07.md`](implementation/SESSION_COMPLETE_2025_11_07.md) - Nov 7 session
- [`implementation/SESSION_FIXES_COMPLETE.md`](implementation/SESSION_FIXES_COMPLETE.md) - Session fixes
- [`implementation/SESSION_PERSISTENCE_STATUS.md`](implementation/SESSION_PERSISTENCE_STATUS.md) - Session state
- [`implementation/JWT_MIGRATION_COMPLETE.md`](implementation/JWT_MIGRATION_COMPLETE.md) - JWT migration
- [`implementation/CHANGES_APPLIED.md`](implementation/CHANGES_APPLIED.md) - Change log

---

### **Testing**

- [`testing/MANUAL_TESTING_CHECKLIST.md`](testing/MANUAL_TESTING_CHECKLIST.md) - Manual test scenarios
- [`testing/TEST_RESULTS.md`](testing/TEST_RESULTS.md) - Test execution results
- [`testing/DELETE_DIAGNOSTIC_REPORT.md`](testing/DELETE_DIAGNOSTIC_REPORT.md) - Delete feature diagnostics

---

### **Architecture & Patterns**

- [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md) - Architecture overview, state management (Riverpod), routing, error handling
- [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md) - Step-by-step implementation patterns
- [`GAP_ANALYSIS.md`](GAP_ANALYSIS.md) - Feature gaps and roadmap

---

### **Maintenance & Diagnostics**

- [`DELETE_DIAGNOSTIC_REPORT.md`](testing/DELETE_DIAGNOSTIC_REPORT.md) - Delete functionality diagnostics
- [`THEME_DARK_MODE_IMPROVEMENTS.md`](THEME_DARK_MODE_IMPROVEMENTS.md) - Dark mode theming

---

## 🎯 Current Project Status (November 9, 2025)

### ✅ **Production Ready**
- Authentication & OTP login
- Session management
- Analytics dashboard
- Service types management

### ✅ **Completed - Awaiting Backend Integration**
- **End-Users Management:** Frontend 100% complete (Nov 9, 2025)
  - ✅ Complete CRUD operations (13 files, ~2,500 lines)
  - ✅ User detail with 6 tabs (Profile, Activity, Bookings, Payments, Reviews, Disputes)
  - ✅ Mock data fallback ready
  - ⏳ 18 backend endpoints pending implementation

- **Vendor Management:** Frontend 30% complete, backend P0/P1 complete
  - ✅ List, details, approve/reject
  - ✅ Backend APIs: application, services, bookings, revenue, leads, payouts, analytics, documents
  - ⏳ Frontend integration with new backend endpoints

### 🔴 **Critical Issues**
- **Vendors API:** Returns 200 OK but with invalid response body (should return vendor data)
- **Users API:** Endpoint not implemented (404) - blocks end-user management testing
- See: [`backend-tickets/BACKEND_TICKET_CRITICAL_API_ERRORS.md`](backend-tickets/BACKEND_TICKET_CRITICAL_API_ERRORS.md)

### 📋 **Planned**
- P2/P3 vendor endpoints (service approval, notifications, bulk ops)
- Advanced analytics features
- Enhanced reporting

---

## 🔍 Finding Documentation

### **By Feature:**
- Users → `features/users/`
- Vendors → `features/vendors/` + `backend/VENDOR_*`
- Analytics → `api/` (analytics endpoints)
- Services → `api/SERVICES_*`

### **By Type:**
- API contracts → `api/`
- Backend requirements → `backend/`
- Configuration → `config/`
- Deployment → `deployment/`
- Implementation tracking → `implementation/`
- Testing → `testing/`

### **By Status:**
- Completed work → `implementation/*_COMPLETE.md`, `features/users/USERS_IMPLEMENTATION_COMPLETE.md`
- Current status → `implementation/IMPLEMENTATION_STATUS.md`
- Production readiness → `deployment/PRODUCTION_READY_*`
- Critical issues → `backend-tickets/BACKEND_TICKET_CRITICAL_API_ERRORS.md`
- Outstanding issues → `backend/BACKEND_TODO.md`

### **By Date:**
- Session notes → `session-notes/YYYY-MM-DD/`
- Latest session → `session-notes/2025-11-09/`

---

## 📖 Common Workflows

### **I want to...**

#### Run the app locally
→ [`QUICK_START.md`](QUICK_START.md)

#### Understand the codebase structure
→ [`DEVELOPER_GUIDE.md`](DEVELOPER_GUIDE.md)

#### Configure environment variables
→ [`config/ENV_INJECTION_GUIDE.md`](config/ENV_INJECTION_GUIDE.md)

#### See available API endpoints
→ [`api/ADMIN_API_QUICK_REFERENCE.md`](api/ADMIN_API_QUICK_REFERENCE.md)

#### Deploy to production
→ [`deployment/DEPLOYMENT_GUIDE.md`](deployment/DEPLOYMENT_GUIDE.md)

#### Implement a new feature
→ [`IMPLEMENTATION_GUIDE.md`](IMPLEMENTATION_GUIDE.md)

#### Integrate vendor management
→ [`features/vendors/VENDOR_MANAGEMENT_FRONTEND_STATUS.md`](features/vendors/VENDOR_MANAGEMENT_FRONTEND_STATUS.md)  
→ [`backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md`](backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md)

#### Fix authentication issues
→ [`api/ADMIN_TOKEN_SETUP.md`](api/ADMIN_TOKEN_SETUP.md)

#### Run tests
→ [`testing/MANUAL_TESTING_CHECKLIST.md`](testing/MANUAL_TESTING_CHECKLIST.md)

#### Understand what's been implemented
→ [`implementation/IMPLEMENTATION_STATUS.md`](implementation/IMPLEMENTATION_STATUS.md)

---

## 🏗️ Project Architecture

```
appydex-admin/
├── lib/
│   ├── core/                 # Core utilities (API client, permissions)
│   ├── models/               # Data models
│   ├── repositories/         # API repositories
│   ├── providers/            # Riverpod state management
│   ├── features/             # Feature screens
│   │   ├── analytics/
│   │   ├── auth/
│   │   ├── services/
│   │   ├── users/
│   │   └── vendors/
│   └── widgets/              # Reusable UI components
├── docs/                     # This directory
└── integration_test/         # Integration tests
```

---

## 🔧 Admin Foundations

- **Authentication**: Admin endpoints now use JWT Bearer tokens only via the `Authorization: Bearer <token>` header. The legacy `X-Admin-Token` header is deprecated and no longer sent by the client.
- **Mock fallback**: enable QA mode with `mockModeProvider` (e.g. via diagnostics) to render sample vendors/subscriptions/audit rows when admin endpoints are missing.
- **Repositories**: use `VendorRepository`, `SubscriptionRepository`, and `AuditRepository` for paginated admin data; each throws `AdminEndpointMissing` to signal missing backend routes.
- **CSV export**: call `toCsv` from `lib/core/export_util.dart` with the current filter rows to generate client-side exports.
- **Analytics**: `AnalyticsClient` fetches Prometheus metrics from `/metrics` (falling back to `/api/v1/admin/metrics` when available).
- **Tests**: run `flutter test` to cover ApiClient admin plumbing, export util, and repository fallbacks.
- **Screens**: dashboard, vendors, subscriptions, and audit logs all live under the admin shell; use the left navigation to switch views.
- **Mock toggle in UI**: when an admin endpoint is missing you'll see a card with "Use mock data" - toggling it pulls data from `MockAdminFallback` so flows stay testable.
- **Trace-aware snackbars**: all success/error operations surface the latest `x-trace-id`; copy it straight from the snackbar for backend follow-up.

### Sample cURL Commands

```bash
BASE=https://api.appydex.co

# List vendors (admin)
curl -X GET "$BASE/api/v1/admin/vendors?page=1&page_size=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Vendor detail
curl -X GET "$BASE/api/v1/admin/vendors/123" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Verify vendor via PATCH
curl -X PATCH "$BASE/api/v1/admin/vendors/123" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"is_verified":true,"notes":"Verified via UI"}'

# List subscriptions
curl -X GET "$BASE/api/v1/admin/subscriptions?page=1&page_size=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Activate subscription
curl -X POST "$BASE/api/v1/subscriptions/42/activate" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"paid_months":3}'
```

---

## ⚠️ Troubleshooting

- **Dio Web**: GET/HEAD requests automatically disable sendTimeout to avoid browser fetch errors; payload requests continue to respect the configured timeout.
- **Diagnostics**: calls `/healthz` at the root of the API host (not under `/api/v1`); a 404 usually means the infra endpoint is missing.
- **OTP**: The `last-otp` endpoint is not implemented by default--use backend tooling if you need OTP visibility.

---

## 📞 Getting Help

1. **Check existing docs:** Use the index above to find relevant documentation
2. **Search by keyword:** Most docs have descriptive filenames
3. **Check implementation status:** See `implementation/` for current progress
4. **Review API contracts:** See `api/` for endpoint specifications
5. **Check backend requirements:** See `backend/` for missing/required endpoints

---

## 🔄 Documentation Maintenance

When updating documentation:
1. Update the relevant section in this README
2. Keep the "Last Updated" date current
3. Update status indicators (✅ 🚧 ⏳)
4. Cross-reference related documents
5. Keep file naming consistent (`FEATURE_STATUS.md`, `FEATURE_COMPLETE.md`, etc.)

---

---

## 📅 Session Notes

Recent development sessions are documented in `session-notes/` organized by date:
- [`session-notes/2025-11-09/`](session-notes/2025-11-09/) - End-User Management Implementation & Backend API Investigation

---

**Documentation Status:** ✅ Complete & Organized  
**Last Reviewed:** November 9, 2025  
**Total Documents:** 60+  
**Coverage:** API, Backend, Config, Deployment, Features, Implementation, Testing, Session Notes

````
