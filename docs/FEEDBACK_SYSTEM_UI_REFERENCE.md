# Feedback System - UI Component Reference

**Quick visual guide for developers and testers**

---

## 1. Feedback List Screen (`/feedback`)

### Stats Banner (Top)
```
┌─────────────────────────────────────────────────────────────────┐
│  📊 156           ⏳ 12             ✓ 57.1%        ⏱ 2.3h       │
│  Total Feedback   Pending Review    Response Rate  Avg Response │
└─────────────────────────────────────────────────────────────────┘
```

### Filters Panel
```
┌─────────────────────────────────────────────────────────────────┐
│  Category: [All ▼]  Status: [Pending ▼]  Priority: [High ▼]    │
│  Submitter: [All ▼]  [Clear Filters]                            │
└─────────────────────────────────────────────────────────────────┘
```

### Data Table
```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ ID  │ Title                    │ Category     │ Status      │ Priority │ Submitter│
├─────┼─────────────────────────┼──────────────┼─────────────┼──────────┼──────────┤
│ #158│ Payment gateway timeout │ [Bug Report] │ [Pending]   │ [High]   │ Premium  │
│     │                          │              │             │          │ Cleaners │
│ #157│ Add CSV export          │ [Feature]    │ [Planned]   │ [Medium] │ John Doe │
└─────┴─────────────────────────┴──────────────┴─────────────┴──────────┴──────────┘

 Votes │ Comments │ Visibility │ Created      │ Actions
───────┼──────────┼────────────┼──────────────┼─────────
 8     │ 2        │ 🌐 Public  │ Nov 11, 2025 │ [→]
 0     │ 0        │ 🌐 Public  │ Nov 11, 2025 │ [→]
```

### Pagination
```
┌─────────────────────────────────────────────────────────────────┐
│  Showing 1-50 of 156        [◀] Page 1 of 4 [▶]                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Feedback Detail Screen (`/feedback/detail/{id}`)

### Layout Structure
```
┌────────────────────────────────────────────────────────────────────────┐
│  [← Back]  Payment gateway timeout on large transactions              │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌─────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ FEEDBACK DETAILS            │  │ ADMIN ACTIONS                  │ │
│  │                             │  │                                │ │
│  │ [Bug Report] [Pending]      │  │ Status: [Pending ▼]           │ │
│  │ [High] [🌐 Public]          │  │ Priority: [High ▼]            │ │
│  │                             │  │                                │ │
│  │ Description:                │  │ ⚪ Public Visibility          │ │
│  │ Transactions over $500...   │  │   Visible on landing page     │ │
│  │                             │  │                                │ │
│  │ Submitted By:               │  └────────────────────────────────┘ │
│  │ 🙍 Premium Cleaners LLC     │                                     │
│  │    Vendor • ID: 42          │  ┌────────────────────────────────┐ │
│  │                             │  │ ADD ADMIN RESPONSE             │ │
│  │ ↑ 8 votes  💬 2 comments    │  │                                │ │
│  │ 🕐 Created Nov 11, 2025     │  │ Response:                     │ │
│  │                             │  │ ┌────────────────────────────┐ │ │
│  └─────────────────────────────┘  │ │ [Write response...]        │ │ │
│                                    │ │                            │ │ │
│  ┌─────────────────────────────┐  │ └────────────────────────────┘ │ │
│  │ COMMENTS (2)                │  │                                │ │
│  │                             │  │ Auto-set status: [Keep ▼]     │ │
│  │ ┌──────────────────────────┐│  │                                │ │
│  │ │ 🙍 Premium Cleaners      ││  │ [Submit Response]              │ │
│  │ │ vendor • Nov 11, 10:30   ││  │                                │ │
│  │ │                          ││  └────────────────────────────────┘ │
│  │ │ This is blocking our...  ││                                     │
│  │ └──────────────────────────┘│                                     │
│  │                             │                                     │
│  │ ┌──────────────────────────┐│                                     │
│  │ │ 👑 AppyDex Team [ADMIN]  ││                                     │
│  │ │ admin • Nov 11, 11:00    ││                                     │
│  │ │                          ││                                     │
│  │ │ We're investigating...   ││                                     │
│  │ └──────────────────────────┘│                                     │
│  └─────────────────────────────┘                                     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Color Coding Reference

### Category Chips
- 🔵 **Blue** - Feature Request
- 🔴 **Red** - Bug Report
- 🟢 **Green** - Improvement
- 🟣 **Purple** - UX Feedback
- 🟠 **Orange** - Performance
- ⚫ **Grey** - General

### Status Chips
- ⚫ **Grey** - Pending
- 🔵 **Blue** - Under Review
- 🔷 **Cyan** - Planned
- 🟠 **Orange** - In Progress
- 🟢 **Green** - Completed
- 🔴 **Red** - Declined

### Priority Chips
- 🔵 **Blue** - Low
- 🟠 **Orange** - Medium
- 🔴 **Red** - High
- 🟣 **Purple** - Critical

### Visibility Icons
- 🌐 **Globe** - Public (visible on landing page)
- 🔒 **Lock** - Private (admin only)

---

## 4. Interactive Elements

### Dropdown Menus
```
Status Dropdown:
┌─────────────────┐
│ Pending         │ ← Current
│ Under Review    │
│ Planned         │
│ In Progress     │
│ Completed       │
│ Declined        │
└─────────────────┘
```

### Toggle Switch
```
Public Visibility
[ON]─────●  Visible on landing page
[OFF] ●───── Hidden from public
```

### Response Form
```
┌──────────────────────────────────────┐
│ Response:                            │
│ ┌──────────────────────────────────┐ │
│ │ Thank you for reporting this...  │ │
│ │                                  │ │
│ │                                  │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Auto-set status: [In Progress ▼]    │
│                                      │
│         [Submit Response]            │
└──────────────────────────────────────┘
```

---

## 5. Empty States

### No Feedback Found
```
        🗣️
   No feedback found
  Try adjusting filters
```

### No Comments Yet
```
        💬
   No comments yet
```

---

## 6. Loading States

### Stats Loading
```
┌─────────────────────────────────────┐
│          ⏳ Loading...              │
└─────────────────────────────────────┘
```

### Table Loading
```
┌─────────────────────────────────────┐
│                                     │
│          ⏳ Loading feedback...     │
│                                     │
└─────────────────────────────────────┘
```

---

## 7. Error States

### Network Error
```
        ⚠️
  Error loading feedback
  Failed to connect to server
     [Retry Button]
```

### Not Found
```
        🔍
  Feedback not found
  The requested feedback may
  have been deleted
```

---

## 8. Toast Notifications

### Success Messages
```
✅ Status updated successfully
✅ Priority updated successfully
✅ Feedback is now public
✅ Response submitted successfully
```

### Error Messages
```
❌ Error updating status: [reason]
❌ Error submitting response: [reason]
❌ Session expired. Please log in again.
```

---

## 9. Navigation Flow

```
Sidebar Menu
    │
    ├─ Feedback (Click)
    │     │
    │     └─ Feedback List Screen
    │           │
    │           ├─ Apply Filters
    │           ├─ View Stats
    │           ├─ Paginate Results
    │           │
    │           └─ Click [→] Action
    │                 │
    │                 └─ Feedback Detail Screen
    │                       │
    │                       ├─ Update Status ✓
    │                       ├─ Set Priority ✓
    │                       ├─ Toggle Visibility ✓
    │                       ├─ Submit Response ✓
    │                       │
    │                       └─ [← Back] to List
    │
    └─ [Continue to other sections...]
```

---

## 10. Keyboard Shortcuts (Future Enhancement)

**Not yet implemented - planning for v2**

- `Ctrl/Cmd + K` - Focus search/filter
- `Ctrl/Cmd + R` - Add response
- `Ctrl/Cmd + S` - Submit response
- `Esc` - Close dialogs/back
- `←` / `→` - Navigate pages
- `1-6` - Quick status update

---

## 11. Responsive Breakpoints

### Desktop (> 1000px)
- Two-column detail layout
- Full table with all columns
- Sidebar navigation

### Tablet/Mobile (< 1000px)
- Single-column detail layout
- Horizontal scroll for table
- Drawer navigation

---

## 12. Accessibility Features

- ✅ Semantic HTML structure
- ✅ Keyboard navigation support
- ✅ Color contrast compliance
- ✅ Icon + text labels
- ✅ Error message descriptions
- ✅ Loading state announcements
- 🔲 Screen reader optimization (planned)
- 🔲 Focus indicators (planned)

---

## Testing Checklist (Visual QA)

### List Screen
- [ ] Stats cards display correctly
- [ ] Filters align properly
- [ ] Table columns sized appropriately
- [ ] Chips have correct colors
- [ ] Pagination controls work
- [ ] Empty state shows correctly
- [ ] Loading spinner centered
- [ ] Error state displays properly

### Detail Screen
- [ ] Two-column layout (desktop)
- [ ] Cards have proper spacing
- [ ] Chips render correctly
- [ ] Comments thread readable
- [ ] Admin badge prominent
- [ ] Form inputs styled properly
- [ ] Buttons have hover states
- [ ] Toast notifications visible

### Interactions
- [ ] Dropdowns open/close smoothly
- [ ] Toggle switch animates
- [ ] Submit button shows loading
- [ ] Navigation transitions smooth
- [ ] Filters update instantly
- [ ] Page changes work
- [ ] Back button navigates correctly

---

**End of UI Reference Guide**
