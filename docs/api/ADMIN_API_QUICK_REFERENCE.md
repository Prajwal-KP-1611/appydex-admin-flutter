# Admin API - Quick Reference Guide

**For Frontend Developers**

## Table of Contents

1. [Authentication](#authentication)
2. [Common Patterns](#common-patterns)
3. [Repository Guide](#repository-guide)
4. [Error Handling](#error-handling)
5. [UI Integration Examples](#ui-integration-examples)

---

## Authentication

⚠️ **UPDATED (Nov 10, 2025):** Admin authentication now uses **password-only login**.

### Login Flow
```dart
// Single-step password-only login
await ref.read(adminSessionProvider.notifier).login(
  email: 'admin@appydex.com',
  password: 'SecurePassword123',
);

// Response includes access_token, csrf_token, user details, roles
```

### API Endpoint
```http
POST /api/v1/admin/auth/login
Content-Type: application/json

{
  "email_or_phone": "admin@appydex.com",
  "password": "SecurePassword123"
}
```

### ❌ Deprecated: OTP Flow
```dart
// ⚠️ DEPRECATED - Do not use
// POST /admin/auth/request-otp returns HTTP 410 GONE
```

### Using Bearer Token
All API calls automatically include the JWT token when using `requestAdmin()`:

```dart
final response = await apiClient.requestAdmin<Map<String, dynamic>>(
  '/admin/vendors',  // Token added automatically
);
```

---

## Common Patterns

### List with Pagination
```dart
// Skip/Limit pagination (most endpoints)
final vendors = await vendorRepo.list(
  skip: 0,
  limit: 100,
  status: 'pending',
);

// Page-based pagination (invoices, audit logs)
final invoices = await invoiceRepo.list(
  page: 1,
  pageSize: 50,
  actorType: 'subscription',
);
```

### Using State Notifiers
```dart
class VendorsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsProvider);
    
    return vendorsAsync.when(
      data: (pagination) => ListView.builder(
        itemCount: pagination.items.length,
        itemBuilder: (context, index) => VendorCard(pagination.items[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

### Filtering Lists
```dart
// Filter by status
ref.read(vendorsProvider.notifier).filterByStatus('verified');

// Search
ref.read(vendorsProvider.notifier).search('ABC Plumbing');

// Clear filters
ref.read(vendorsProvider.notifier).clearFilters();
```

---

## Repository Guide

### Admin Account Management

**Repository:** `adminUserRepositoryProvider`

```dart
// List all admins
final admins = await adminRepo.list(skip: 0, limit: 100);

// Get admin by ID
final admin = await adminRepo.getById(userId);

// Create new admin
final newAdmin = await adminRepo.create(AdminUserRequest(
  email: 'admin@example.com',
  password: 'SecurePass123!',
  role: 'vendor_admin',
  name: 'New Admin',
));

// Update admin
final updated = await adminRepo.update(userId, AdminUserUpdateRequest(
  email: 'newemail@example.com',
  name: 'Updated Name',
));

// Delete admin
await adminRepo.delete(userId);
```

### Role Management

**Repository:** `roleRepositoryProvider`

```dart
// List available roles
final roles = await roleRepo.getAvailableRoles();

// Assign role
await roleRepo.assignRole(userId: 10, role: 'reviews_admin');

// Revoke role
await roleRepo.revokeRole(userId: 10, role: 'vendor_admin');
```

### Vendor Management

**Repository:** `vendorRepositoryProvider`

```dart
// List vendors with filters
final vendors = await vendorRepo.list(
  skip: 0,
  limit: 100,
  status: 'pending',
  search: 'ABC',
);

// Get vendor details
final vendor = await vendorRepo.get(vendorId);

// Verify/Approve vendor
await vendorRepo.verifyOrReject(
  id: vendorId,
  action: 'approve',
  notes: 'All documents verified',
);

// Reject vendor
await vendorRepo.verifyOrReject(
  id: vendorId,
  action: 'reject',
  notes: 'Missing business license',
);
```

### Plan Management

**Repository:** `planRepositoryProvider`

```dart
// List plans (with optional filter)
final activePlans = await planRepo.list(isActive: true);
final allPlans = await planRepo.list();

// Create plan
final plan = await planRepo.create(PlanRequest(
  code: 'premium_monthly',
  name: 'Premium Monthly',
  priceCents: 9900,
  durationDays: 30,
  trialDays: 14,
));

// Update plan
await planRepo.update(planId, PlanRequest(priceCents: 10900));

// Deactivate (soft delete)
await planRepo.deactivate(planId);

// Reactivate
await planRepo.reactivate(planId);

// Hard delete
await planRepo.hardDelete(planId);
```

### Service Type Requests

**Repository:** `serviceTypeRequestRepositoryProvider`

```dart
// List pending requests
final requests = await requestRepo.list(status: 'pending');

// Approve request (creates new ServiceType)
await requestRepo.approve(
  requestId: requestId,
  reviewNotes: 'Great addition!',
);

// Reject request (min 20 chars feedback)
await requestRepo.reject(
  requestId: requestId,
  reviewNotes: 'Too similar to existing category. Please review our catalog...',
);

// Get SLA statistics
final stats = await requestRepo.getStats();
```

### Subscription Management

**Repository:** `subscriptionRepositoryProvider`

```dart
// List subscriptions
final subs = await subRepo.list(status: 'active', vendorId: 42);

// Cancel subscription
await subRepo.cancel(
  subscriptionId: subId,
  reason: 'Customer request',
  immediate: false,  // Cancel at period end
);

// Extend subscription
await subRepo.extend(
  subscriptionId: subId,
  days: 30,
  reason: 'Promotional extension',
);
```

### Campaign Management

**Repository:** `campaignRepositoryProvider`

```dart
// List promo ledger
final ledger = await campaignRepo.listPromoLedger(
  vendorId: 42,
  campaignType: 'referral_bonus',
);

// Credit promo days manually
await campaignRepo.creditPromoDays(
  vendorId: 42,
  days: 30,
  campaignType: 'admin_compensation',
  description: 'Compensation for service outage',
);

// Get campaign statistics
final stats = await campaignRepo.getCampaignStats();
```

### Invoice Management 🆕

**Repository:** `invoiceRepositoryProvider`

```dart
// List invoices
final invoices = await invoiceRepo.list(
  page: 1,
  pageSize: 50,
  actorType: 'subscription',
  search: 'INV-123',
);

// Get invoice details
final invoice = await invoiceRepo.getById(invoiceId);

// Download PDF
final pdfBytes = await invoiceRepo.downloadPdf(invoiceId);
// Save to file or display

// Resend email
await invoiceRepo.resendEmail(
  invoiceId: invoiceId,
  email: 'accounting@example.com',  // Optional custom email
);

// Get statistics
final stats = await invoiceRepo.getStatsSummary();
```

### Audit Logs

**Repository:** `auditRepositoryProvider`

```dart
// List audit logs
final logs = await auditRepo.list(
  action: 'vendor_verification_approved',
  subjectType: 'vendor',
  from: DateTime.now().subtract(Duration(days: 7)),
  page: 1,
  pageSize: 50,
);

// Get detailed audit entry
final detail = await auditRepo.getById(logId);

// Get available actions for filters
final actions = await auditRepo.listActions();

// Get available resource types for filters
final types = await auditRepo.listResourceTypes();
```

### System Health 🆕

**Repository:** `systemRepositoryProvider`

```dart
// Get ephemeral data statistics
final stats = await systemRepo.getEphemeralStats();

// Access stats
print('Idempotency keys: ${stats.idempotencyKeys.total}');
print('Last 7 days: ${stats.idempotencyKeys.last7Days}');
print('Refresh tokens: ${stats.refreshTokens.active} active');
```

---

## Error Handling

### Standard Pattern
```dart
try {
  final result = await repository.someOperation();
  // Handle success
} on AdminEndpointMissing catch (e) {
  // Backend endpoint not implemented yet
  showError('Feature not available: ${e.endpoint}');
} on DioException catch (e) {
  // HTTP error
  final statusCode = e.response?.statusCode;
  final message = e.response?.data?['message'] ?? 'Request failed';
  showError(message);
} catch (e) {
  // Generic error
  showError('An unexpected error occurred');
}
```

### Specific Exceptions

**OTP Errors:**
```dart
try {
  await otpRepo.requestOtp(emailOrPhone: email);
} on OtpException catch (e) {
  showError(e.message);  // Specific API error message
}
```

**Admin Endpoint Missing:**
```dart
try {
  await adminRepo.someOperation();
} on AdminEndpointMissing catch (e) {
  showError('Backend endpoint not implemented: ${e.endpoint}');
}
```

---

## UI Integration Examples

### Create Admin Dialog
```dart
Future<void> _showCreateAdminDialog(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'vendor_admin';

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Create Admin'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) => value?.contains('@') == true 
                  ? null 
                  : 'Invalid email',
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value?.length >= 8 
                  ? null 
                  : 'Min 8 characters',
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: [
                DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                DropdownMenuItem(value: 'vendor_admin', child: Text('Vendor Admin')),
                DropdownMenuItem(value: 'reviews_admin', child: Text('Reviews Admin')),
              ],
              onChanged: (value) => selectedRole = value!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            
            try {
              await ref.read(adminUsersProvider.notifier).createUser(
                AdminUserRequest(
                  email: emailController.text,
                  password: passwordController.text,
                  role: selectedRole,
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Admin created successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}
```

### Vendor Approval Card
```dart
class VendorApprovalCard extends ConsumerWidget {
  final Vendor vendor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(vendor.companyName),
            subtitle: Text(vendor.email),
          ),
          ButtonBar(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Approve'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  try {
                    await ref.read(vendorRepositoryProvider).verifyOrReject(
                      id: vendor.id,
                      action: 'approve',
                      notes: 'All documents verified',
                    );
                    ref.read(vendorsProvider.notifier).load();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vendor approved')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
              OutlinedButton.icon(
                icon: Icon(Icons.close),
                label: Text('Reject'),
                onPressed: () => _showRejectDialog(context, ref, vendor.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Invoice PDF Download
```dart
Future<void> _downloadInvoicePdf(
  BuildContext context,
  WidgetRef ref,
  int invoiceId,
  String invoiceNumber,
) async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Download PDF
    final pdfBytes = await ref.read(invoiceRepositoryProvider).downloadPdf(invoiceId);

    // Close loading
    Navigator.pop(context);

    // On web: trigger download
    if (kIsWeb) {
      final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$invoiceNumber.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // On mobile: save to downloads or share
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$invoiceNumber.pdf');
      await file.writeAsBytes(pdfBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    }
  } catch (e) {
    Navigator.pop(context);  // Close loading if still open
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  }
}
```

### Statistics Dashboard Card
```dart
class InvoiceStatsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(invoiceStatsProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice Statistics', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              _buildStatRow('Total Invoices', stats.totalInvoices.toString()),
              _buildStatRow('Total Revenue', stats.formattedRevenue),
              _buildStatRow('Total Tax', stats.formattedTax),
              _buildStatRow('Total Gross', stats.formattedGross),
              SizedBox(height: 16),
              Text('By Type', style: Theme.of(context).textTheme.titleMedium),
              ...stats.byActorType.map((stat) => _buildStatRow(
                stat.actorType.toUpperCase(),
                '${stat.count} invoices • ${stat.formattedRevenue}',
              )),
            ],
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error loading stats'),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

---

## Provider Cheat Sheet

### Repository Providers (Singleton)
```dart
adminUserRepositoryProvider
roleRepositoryProvider
vendorRepositoryProvider
serviceRepositoryProvider
serviceTypeRepositoryProvider
serviceTypeRequestRepositoryProvider
subscriptionRepositoryProvider
planRepositoryProvider
campaignRepositoryProvider
paymentRepositoryProvider
invoiceRepositoryProvider  🆕
auditRepositoryProvider
systemRepositoryProvider  🆕
otpRepositoryProvider
```

### State Notifier Providers (List Management)
```dart
adminUsersProvider
vendorsProvider
servicesProvider
serviceTypeRequestsProvider
subscriptionsProvider
plansProvider
promoLedgerProvider
paymentsProvider
invoicesProvider  🆕
```

### Future Providers (One-time Fetch)
```dart
campaignStatsProvider
invoiceStatsProvider  🆕
ephemeralStatsProvider  🆕 (auto-refresh)
auditActionsProvider  🆕 (cached)
auditResourceTypesProvider  🆕 (cached)
```

---

## Common Query Parameters

**Most Endpoints:**
- `skip` - Pagination offset (default: 0)
- `limit` - Max records (default: 100)
- `search` - Search query
- `status` - Status filter

**Invoice & Audit Endpoints:**
- `page` - Page number (1-indexed)
- `page_size` - Records per page

**Date Filters (Audit):**
- `created_after` - ISO 8601 datetime
- `created_before` - ISO 8601 datetime

---

## Testing Checklist

- [ ] Login with OTP shows success message
- [ ] Login errors display specific backend messages
- [ ] Admin CRUD operations work
- [ ] Role assignment/revocation works
- [ ] Vendor approval/rejection works
- [ ] Service type requests approve/reject
- [ ] Plan lifecycle (create, update, deactivate, reactivate)
- [ ] Subscription cancel/extend
- [ ] Campaign promo credits
- [ ] Invoice list/download/resend
- [ ] Audit log filters populate from API
- [ ] System health stats display
- [ ] Error messages are user-friendly
- [ ] Loading states show correctly
- [ ] Pagination works

---

**Last Updated:** November 5, 2025  
**See Also:** [API Alignment Implementation Summary](./API_ALIGNMENT_IMPLEMENTATION.md)
