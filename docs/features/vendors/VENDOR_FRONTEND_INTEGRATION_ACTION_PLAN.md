# Vendor Management - Frontend Integration Action Plan

**Date:** November 9, 2025  
**Status:** 🚀 Backend P0/P1 Complete - Ready for Frontend Integration  
**Priority:** HIGH - All 9 critical endpoints are now live!

---

## 🎉 Backend Update

The backend team has completed all P0 and P1 vendor management endpoints. All 9 new endpoints are **LIVE and TESTED** as of November 9, 2025:

✅ `/api/v1/admin/vendors/{id}/application`  
✅ `/api/v1/admin/vendors/{id}/services`  
✅ `/api/v1/admin/vendors/{id}/bookings`  
✅ `/api/v1/admin/vendors/{id}/revenue`  
✅ `/api/v1/admin/vendors/{id}/leads`  
✅ `/api/v1/admin/vendors/{id}/payouts`  
✅ `/api/v1/admin/vendors/{id}/analytics`  
✅ `/api/v1/admin/vendors/{id}/documents`  
✅ `/api/v1/admin/vendors/{id}/documents/{doc_id}/verify`

---

## 📋 Frontend Integration Checklist

### Phase 1: Data Models (1-2 hours)

Create models in `lib/models/`:

- [ ] **`vendor_application.dart`**
  ```dart
  class VendorApplication {
    final int vendorId;
    final int userId;
    final String companyName;
    final String registrationStatus; // pending|verified|rejected
    final int registrationProgress; // 0-100
    final String registrationStep;
    final DateTime appliedAt;
    final Map<String, dynamic> applicationData;
    final List<String> incompleteFields;
    final List<VendorDocument> submittedDocuments;
    final List<String> missingDocuments;
    
    factory VendorApplication.fromJson(Map<String, dynamic> json) { ... }
  }
  ```

- [ ] **`vendor_service.dart`**
  ```dart
  class VendorService {
    final String id;
    final int vendorId;
    final String name;
    final String category;
    final String status; // active|inactive
    final ServicePricing pricing;
    final bool isFeatured;
    final DateTime createdAt;
    
    factory VendorService.fromJson(Map<String, dynamic> json) { ... }
  }
  
  class ServicePricing {
    final int basePrice;
    final String currency;
    final String pricingType;
  }
  ```

- [ ] **`vendor_booking.dart`**
  ```dart
  class VendorBooking {
    final String id;
    final String bookingReference;
    final int customerId;
    final String customerName;
    final String status;
    final DateTime bookingDate;
    final int amount;
    final int commission;
    final int vendorPayout;
    final String paymentStatus;
    
    factory VendorBooking.fromJson(Map<String, dynamic> json) { ... }
  }
  
  class VendorBookingSummary {
    final int totalBookings;
    final int pending;
    final int completed;
    final int totalRevenue;
    final int totalCommission;
  }
  ```

- [ ] **`vendor_lead.dart`**
  ```dart
  class VendorLead {
    final String id;
    final String customerName;
    final String customerPhone;
    final String? customerEmail;
    final String status; // new|contacted|won|lost
    final String message;
    final String source; // website|app|referral
    final DateTime createdAt;
    
    factory VendorLead.fromJson(Map<String, dynamic> json) { ... }
  }
  
  class VendorLeadSummary {
    final int total;
    final int newLeads;
    final int contacted;
    final int won;
    final double conversionRate;
  }
  ```

- [ ] **`vendor_revenue.dart`**
  ```dart
  class VendorRevenue {
    final RevenueSummary summary;
    final List<RevenueTimeSeries> timeSeries;
    final CommissionBreakdown commissionBreakdown;
    
    factory VendorRevenue.fromJson(Map<String, dynamic> json) { ... }
  }
  
  class RevenueSummary {
    final int totalBookingsValue;
    final int platformCommission;
    final int vendorEarnings;
    final int taxDeducted;
    final int netPayable;
    final int paidAmount;
    final int pendingPayout;
  }
  
  class RevenueTimeSeries {
    final String date;
    final int bookings;
    final int revenue;
    final int commission;
  }
  ```

- [ ] **`vendor_payout.dart`**
  ```dart
  class VendorPayout {
    final String id;
    final String payoutReference;
    final int grossAmount;
    final int netAmount;
    final String status; // pending|completed|failed
    final String paymentMethod;
    final DateTime? processedAt;
    final String? utrNumber;
    
    factory VendorPayout.fromJson(Map<String, dynamic> json) { ... }
  }
  ```

- [ ] **`vendor_analytics.dart`**
  ```dart
  class VendorAnalytics {
    final AnalyticsPeriod period;
    final PerformanceMetrics performance;
    final RevenueMetrics revenue;
    final CustomerMetrics customer;
    final ServiceMetrics service;
    
    factory VendorAnalytics.fromJson(Map<String, dynamic> json) { ... }
  }
  
  class PerformanceMetrics {
    final int totalBookings;
    final int completedBookings;
    final double completionRate;
    final double averageRating;
  }
  ```

---

### Phase 2: Repository Methods (2-3 hours)

Update `lib/repositories/vendor_repo.dart`:

```dart
class VendorRepository {
  final ApiClient _client;
  
  // ... existing methods ...
  
  // NEW METHODS:
  
  Future<VendorApplication> getApplication(int vendorId) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/application',
    );
    return VendorApplication.fromJson(response.data ?? {});
  }
  
  Future<Pagination<VendorService>> getServices(
    int vendorId, {
    String? status,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/services',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
      },
    );
    return Pagination.fromJson(
      response.data ?? {},
      (json) => VendorService.fromJson(json),
    );
  }
  
  Future<({Pagination<VendorBooking> bookings, VendorBookingSummary summary})> getBookings(
    int vendorId, {
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sort = 'created_at',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/bookings',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        'sort': sort,
      },
    );
    
    final data = response.data ?? {};
    final bookings = Pagination.fromJson(
      data,
      (json) => VendorBooking.fromJson(json),
    );
    final summary = VendorBookingSummary.fromJson(data['summary'] ?? {});
    
    return (bookings: bookings, summary: summary);
  }
  
  Future<VendorRevenue> getRevenue(
    int vendorId, {
    DateTime? fromDate,
    DateTime? toDate,
    String groupBy = 'day',
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/revenue',
      queryParameters: {
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        'group_by': groupBy,
      },
    );
    return VendorRevenue.fromJson(response.data ?? {});
  }
  
  Future<({Pagination<VendorLead> leads, VendorLeadSummary summary})> getLeads(
    int vendorId, {
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/leads',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status,
      },
    );
    
    final data = response.data ?? {};
    final leads = Pagination.fromJson(
      data,
      (json) => VendorLead.fromJson(json),
    );
    final summary = VendorLeadSummary.fromJson(data['summary'] ?? {});
    
    return (leads: leads, summary: summary);
  }
  
  Future<Pagination<VendorPayout>> getPayouts(
    int vendorId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/payouts',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return Pagination.fromJson(
      response.data ?? {},
      (json) => VendorPayout.fromJson(json),
    );
  }
  
  Future<VendorAnalytics> getAnalytics(
    int vendorId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/analytics',
      queryParameters: {
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      },
    );
    return VendorAnalytics.fromJson(response.data ?? {});
  }
  
  Future<List<VendorDocument>> getDocuments(int vendorId) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/vendors/$vendorId/documents',
    );
    final items = (response.data?['items'] as List?) ?? [];
    return items.map((json) => VendorDocument.fromJson(json)).toList();
  }
  
  Future<void> verifyDocument(
    int vendorId,
    String documentId, {
    required bool approve,
    String? notes,
  }) async {
    await _client.requestAdmin(
      '/admin/vendors/$vendorId/documents/$documentId/verify',
      method: 'POST',
      data: {
        'status': approve ? 'verified' : 'rejected',
        if (notes != null) 'notes': notes,
      },
    );
  }
}
```

- [ ] Add all 9 new methods to `VendorRepository`
- [ ] Test each method with Postman/curl
- [ ] Handle errors properly

---

### Phase 3: Riverpod Providers (1 hour)

Create providers in `lib/providers/vendor_providers.dart`:

```dart
// Application provider
final vendorApplicationProvider = FutureProvider.family<VendorApplication, int>(
  (ref, vendorId) async {
    final repo = ref.read(vendorRepositoryProvider);
    return repo.getApplication(vendorId);
  },
);

// Services provider with filters
final vendorServicesProvider = FutureProvider.family<
  Pagination<VendorService>,
  ({int vendorId, String? status, String? category, int page})
>(
  (ref, params) async {
    final repo = ref.read(vendorRepositoryProvider);
    return repo.getServices(
      params.vendorId,
      status: params.status,
      category: params.category,
      page: params.page,
    );
  },
);

// Bookings provider
final vendorBookingsProvider = FutureProvider.family<
  ({Pagination<VendorBooking> bookings, VendorBookingSummary summary}),
  ({int vendorId, String? status, DateTime? fromDate, DateTime? toDate, int page})
>(
  (ref, params) async {
    final repo = ref.read(vendorRepositoryProvider);
    return repo.getBookings(
      params.vendorId,
      status: params.status,
      fromDate: params.fromDate,
      toDate: params.toDate,
      page: params.page,
    );
  },
);

// ... similar for leads, revenue, payouts, analytics, documents
```

- [ ] Create providers for all 8 tabs
- [ ] Add auto-refresh capability
- [ ] Handle loading/error states

---

### Phase 4: UI Tabs (4-6 hours)

Update `lib/features/vendors/vendor_detail_screen.dart`:

Add new tabs to the existing screen:

```dart
class VendorDetailScreen extends ConsumerStatefulWidget {
  // ... existing code ...
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 9, // Increased from current to 9 tabs
      vsync: this,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final vendorState = ref.watch(vendorDetailProvider(widget.vendorId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Application'), // NEW
            Tab(text: 'Services'),    // NEW
            Tab(text: 'Bookings'),    // NEW
            Tab(text: 'Leads'),       // NEW
            Tab(text: 'Revenue'),     // NEW
            Tab(text: 'Payouts'),     // NEW
            Tab(text: 'Analytics'),   // NEW
            Tab(text: 'Documents'),   // ENHANCED
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(vendor),
          _buildApplicationTab(vendor),  // NEW
          _buildServicesTab(vendor),     // NEW
          _buildBookingsTab(vendor),     // NEW
          _buildLeadsTab(vendor),        // NEW
          _buildRevenueTab(vendor),      // NEW
          _buildPayoutsTab(vendor),      // NEW
          _buildAnalyticsTab(vendor),    // NEW
          _buildDocumentsTab(vendor),    // ENHANCED
        ],
      ),
    );
  }
  
  Widget _buildApplicationTab(Vendor vendor) {
    final applicationState = ref.watch(vendorApplicationProvider(vendor.id));
    
    return applicationState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorWidget.withDetails(
        message: 'Failed to load application',
        error: err.toString(),
      ),
      data: (application) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Registration Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: application.registrationProgress / 100,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text('${application.registrationProgress}% Complete'),
                    const SizedBox(height: 8),
                    Text(
                      'Current Step: ${application.registrationStep}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Incomplete fields
            if (application.incompleteFields.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Incomplete Fields',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...application.incompleteFields.map(
                        (field) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.warning_amber, size: 16),
                          title: Text(field),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Missing documents
            if (application.missingDocuments.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📄 Missing Documents',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...application.missingDocuments.map(
                        (doc) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.description_outlined, size: 16),
                          title: Text(doc),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Implement similar methods for other tabs:
  // _buildServicesTab, _buildBookingsTab, _buildLeadsTab,
  // _buildRevenueTab, _buildPayoutsTab, _buildAnalyticsTab, _buildDocumentsTab
}
```

#### Tab Implementation Checklist:

- [ ] **Application Tab** - Progress bar, incomplete fields, missing docs
- [ ] **Services Tab** - Data table with filters, featured badge
- [ ] **Bookings Tab** - Summary cards, bookings table, date filter
- [ ] **Leads Tab** - Summary metrics, leads table, status filter
- [ ] **Revenue Tab** - Summary cards, time series chart, date range
- [ ] **Payouts Tab** - Payout history table, status chips
- [ ] **Analytics Tab** - KPI cards in grid, date range selector
- [ ] **Documents Tab** - Enhanced with verify/reject buttons

---

### Phase 5: Testing (2 hours)

- [ ] Create test vendor in database
- [ ] Test each tab loads correctly
- [ ] Test filters work
- [ ] Test pagination
- [ ] Test date range selectors
- [ ] Test document verification
- [ ] Test error handling
- [ ] Test loading states
- [ ] Test empty states

---

### Phase 6: Polish (1-2 hours)

- [ ] Add icons to tabs
- [ ] Add tooltips
- [ ] Add confirmation dialogs
- [ ] Add success/error snackbars
- [ ] Add export buttons per tab
- [ ] Add refresh buttons
- [ ] Optimize performance
- [ ] Add skeleton loaders

---

## 🎯 Estimated Timeline

- **Models:** 1-2 hours
- **Repository:** 2-3 hours
- **Providers:** 1 hour
- **UI Tabs:** 4-6 hours
- **Testing:** 2 hours
- **Polish:** 1-2 hours

**Total:** 11-16 hours of development

**Suggested Schedule:**
- Day 1: Models + Repository (3-5 hours)
- Day 2: Providers + Start UI (5-7 hours)
- Day 3: Finish UI + Testing + Polish (6-8 hours)

---

## 📝 Notes

- All endpoints are tested and working (404 for non-existent vendor is expected)
- Backend response format is consistent with existing endpoints
- Pagination follows Format B (items + meta)
- All responses wrapped in `{success: true, data: {...}}`
- Frontend interceptor auto-unwraps responses

---

## 🔗 Related Documentation

- **Backend Implementation:** `docs/backend/VENDOR_API_IMPLEMENTATION_COMPLETE.md`
- **Frontend Status:** `docs/features/vendors/VENDOR_MANAGEMENT_FRONTEND_STATUS.md`
- **Backend Requirements:** `docs/backend/BACKEND_VENDOR_MANAGEMENT_ENDPOINTS_REQUIRED.md`
- **API Reference:** `docs/api/ADMIN_API_QUICK_REFERENCE.md`

---

**Action Plan Date:** November 9, 2025  
**Status:** 🚀 READY TO START  
**Priority:** HIGH - All backend endpoints are live!
