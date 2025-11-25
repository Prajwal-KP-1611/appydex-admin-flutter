# AppyDex Admin Application Specification

## Overview

The AppyDex Admin application is a Flutter-based web admin panel for managing the AppyDex transaction platform. It provides administrative oversight and operational tools for managing vendors, users, bookings, payments, and platform operations.

---

## Platform-Mediated Contact (Admin View)

### Business Model

AppyDex is a **transaction platform**, not a contact directory. The core principle is:

> **No booking → No direct contact**

This means:
- Users and vendors should connect **through bookings** made on the platform
- Direct contact information exchange is permitted **only after a booking is confirmed**
- The platform mediates and facilitates these connections to ensure quality, trust, and revenue flow

### Admin Access to Contact Information

#### What Admin Can See

Admin users have access to full contact information for **operational purposes**:

- ✅ **Vendor contact details**: Email, phone number displayed in:
  - Vendor detail pages (`/vendors/detail`)
  - Vendor onboarding queue (`/vendors/onboarding`)
  - Active vendors list (`/vendors/active`)
  
- ✅ **User contact details**: Email, phone number displayed in:
  - User management screens (`/users`)
  - Booking detail pages (user and vendor contact info)
  
- ✅ **Lead information**: Customer contact details submitted through the platform in:
  - Vendor leads tab (shows customer name, phone, email for inquiries)

#### Operational Use Cases

Admin access to contact information is justified for:

1. **Customer Support**: Resolving booking disputes, payment issues, or service complaints
2. **Vendor Onboarding**: Verifying business information and documents
3. **Trust & Safety**: Investigating fraud, abuse, or policy violations
4. **Platform Operations**: Coordinating service delivery, handling emergencies

### Compliance Requirements

#### What Admin Must NOT Do

The admin application **must not provide tools** to systematically bypass the platform model:

- ❌ **No "Share vendor contact with user" features**: One-click actions that facilitate direct contact outside bookings
- ❌ **No "Contact vendor on behalf of user" flows**: Bypassing the booking requirement
- ❌ **No systematic contact extraction**: While CSV exports exist for operational data, they should not be used to create external contact directories

#### Current Implementation Notes

The admin app includes **CSV export functionality** that contains contact information:
- `/vendors/active` - Export CSV with vendor email/phone
- `/vendors/onboarding` - Export CSV with vendor email/phone
- Vendor list screens - Individual vendor CSV copy

**Important**: These exports are tagged with TODO comments indicating they must comply with the platform-mediated contact model. While they serve legitimate operational needs (e.g., bulk vendor outreach for platform updates), admins should not:
- Share these exports with third parties
- Use contact data to facilitate off-platform transactions
- Provide vendor contact details to users without an active booking

### Design Principles

1. **Display is OK, Systematic Sharing is Not**: Admin can view contact details in the UI for support purposes, but should not have tools to easily distribute this information
2. **Context Matters**: Contact information shown in the context of a booking or support ticket is appropriate
3. **Audit Trail**: Administrative actions involving contact information should be logged
4. **Booking-First**: Any feature that connects users and vendors should verify a booking exists first

### Future Considerations

If implementing new admin features that involve contact information:

1. **Ask**: Does this feature bypass the booking requirement?
2. **Verify**: Is there a legitimate operational need?
3. **Document**: Add clear business justification
4. **Tag**: Use TODO comments if the feature needs review for compliance

---

## Related Documentation

- `/docs/VENDOR_DETAIL_PAGE_IMPLEMENTATION.md` - Vendor detail page structure
- `/docs/TESTING_GUIDE.md` - Testing procedures
- `/docs/PRE_PRODUCTION_READINESS.md` - Production deployment checklist
