# Backend Ticket: Implement httpOnly Cookie Refresh Token Flow

**Date:** 2025-11-07
**Requested by:** Frontend Team

## Problem
For production security, the frontend should not persist refresh tokens in localStorage or SharedPreferences. Instead, the backend should set the refresh token as a secure httpOnly cookie (inaccessible to JavaScript).

## Required Changes
- On login, backend sets refresh token as httpOnly cookie.
- Frontend only stores access token in memory.
- On refresh, frontend calls `/auth/refresh` endpoint without sending refresh token in body.
- Backend reads refresh token from httpOnly cookie, issues new access token.
- User stays logged in securely.

## Acceptance Criteria
- Refresh token is never accessible to JavaScript on web clients.
- `/auth/refresh` endpoint supports cookie-based refresh for web.
- Documentation updated for frontend/backend contract.

## References
- See frontend docs: `docs/tickets/BACKEND_HTTPONLY_COOKIE_AUTH.md`
- See open question in: `docs/tickets/BACKEND_MISSING_ENDPOINTS.md`

---
Please confirm when implemented or provide timeline for delivery.