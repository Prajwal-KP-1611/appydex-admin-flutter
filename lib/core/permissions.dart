import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_role.dart';
import 'auth/auth_service.dart';

/// Provider that exposes the current admin's permissions as a Set
/// For now, derive from active role. In future, backend may send explicit permissions list.
final permissionsProvider = Provider<Set<String>>((ref) {
  final session = ref.watch(adminSessionProvider);
  if (session == null) return const <String>{};
  
  final role = session.activeRole;
  
  // Generate permission set based on role
  // TODO: Replace with actual permissions from backend when available
  final permissions = <String>{};
  
  // Super admin gets all permissions
  if (role == AdminRole.superAdmin) {
    permissions.addAll([
      // All permissions
      'vendors:list', 'vendors:view', 'vendors:create', 'vendors:update', 
      'vendors:verify', 'vendors:suspend', 'vendors:export',
      'services:list', 'services:view', 'services:create', 'services:update', 'services:delete',
      'service_type_requests:list', 'service_type_requests:approve', 'service_type_requests:reject',
      'users:list', 'users:view', 'users:update', 'users:suspend', 'users:anonymize',
      'admins:list', 'admins:create', 'admins:update', 'admins:delete', 'admins:impersonate',
      'plans:list', 'plans:create', 'plans:update', 'plans:activate',
      'subscriptions:list', 'subscriptions:view', 'subscriptions:cancel',
      'payments:list', 'payments:view', 'payments:refund', 'payments:export', 'invoices:download',
      'reviews:list', 'reviews:update', 'reviews:flag', 'reviews:appeal',
      'campaigns:list', 'campaigns:create', 'campaigns:update', 'campaigns:manual_credit',
      'audit_logs:list', 'audit_logs:export',
      'analytics:view', 'analytics:export',
      'notifications:send',
      'system:health', 'system:backup', 'system:config',
    ]);
  } else if (role == AdminRole.vendorAdmin) {
    permissions.addAll([
      'vendors:list', 'vendors:view', 'vendors:update', 'vendors:verify', 'vendors:suspend', 'vendors:export',
      'services:list', 'services:view', 'services:create', 'services:update', 'services:delete',
      'service_type_requests:list', 'service_type_requests:approve', 'service_type_requests:reject',
    ]);
  } else if (role == AdminRole.accountsAdmin) {
    permissions.addAll([
      'users:list', 'users:view', 'users:update', 'users:suspend',
      'plans:list', 'plans:create', 'plans:update', 'plans:activate',
      'subscriptions:list', 'subscriptions:view', 'subscriptions:cancel',
      'payments:list', 'payments:view', 'payments:refund', 'payments:export', 'invoices:download',
    ]);
  } else if (role == AdminRole.reviewsAdmin) {
    permissions.addAll([
      'reviews:list', 'reviews:update', 'reviews:flag', 'reviews:appeal',
      'vendors:list', 'vendors:view',
    ]);
  } else if (role == AdminRole.supportAdmin) {
    permissions.addAll([
      'users:list', 'users:view',
      'vendors:list', 'vendors:view',
      'services:list', 'services:view',
      'subscriptions:list', 'subscriptions:view',
      'payments:list', 'payments:view',
      'reviews:list',
    ]);
  }
  
  return permissions;
});

/// Check if the current admin has a specific permission
bool can(WidgetRef ref, String permission) {
  final permissions = ref.read(permissionsProvider);
  return permissions.contains(permission);
}

/// Check if the current admin has ANY of the specified permissions
bool canAny(WidgetRef ref, List<String> permissions) {
  final userPermissions = ref.read(permissionsProvider);
  return permissions.any((p) => userPermissions.contains(p));
}

/// Check if the current admin has ALL of the specified permissions
bool canAll(WidgetRef ref, List<String> permissions) {
  final userPermissions = ref.read(permissionsProvider);
  return permissions.every((p) => userPermissions.contains(p));
}

/// Permission constants for easy reference and autocomplete
class Permissions {
  const Permissions._();
  
  // Vendors
  static const vendorsList = 'vendors:list';
  static const vendorsView = 'vendors:view';
  static const vendorsCreate = 'vendors:create';
  static const vendorsUpdate = 'vendors:update';
  static const vendorsVerify = 'vendors:verify';
  static const vendorsSuspend = 'vendors:suspend';
  static const vendorsExport = 'vendors:export';
  
  // Services
  static const servicesList = 'services:list';
  static const servicesView = 'services:view';
  static const servicesCreate = 'services:create';
  static const servicesUpdate = 'services:update';
  static const servicesDelete = 'services:delete';
  
  // Service Type Requests
  static const serviceTypeRequestsList = 'service_type_requests:list';
  static const serviceTypeRequestsApprove = 'service_type_requests:approve';
  static const serviceTypeRequestsReject = 'service_type_requests:reject';
  
  // Users
  static const usersList = 'users:list';
  static const usersView = 'users:view';
  static const usersUpdate = 'users:update';
  static const usersSuspend = 'users:suspend';
  static const usersAnonymize = 'users:anonymize';
  
  // Admins
  static const adminsList = 'admins:list';
  static const adminsCreate = 'admins:create';
  static const adminsUpdate = 'admins:update';
  static const adminsDelete = 'admins:delete';
  static const adminsImpersonate = 'admins:impersonate';
  
  // Plans
  static const plansList = 'plans:list';
  static const plansCreate = 'plans:create';
  static const plansUpdate = 'plans:update';
  static const plansActivate = 'plans:activate';
  
  // Subscriptions
  static const subscriptionsList = 'subscriptions:list';
  static const subscriptionsView = 'subscriptions:view';
  static const subscriptionsCancel = 'subscriptions:cancel';
  
  // Payments
  static const paymentsList = 'payments:list';
  static const paymentsView = 'payments:view';
  static const paymentsRefund = 'payments:refund';
  static const paymentsExport = 'payments:export';
  static const invoicesDownload = 'invoices:download';
  
  // Reviews
  static const reviewsList = 'reviews:list';
  static const reviewsUpdate = 'reviews:update';
  static const reviewsFlag = 'reviews:flag';
  static const reviewsAppeal = 'reviews:appeal';
  
  // Campaigns/Referrals
  static const campaignsList = 'campaigns:list';
  static const campaignsCreate = 'campaigns:create';
  static const campaignsUpdate = 'campaigns:update';
  static const campaignsManualCredit = 'campaigns:manual_credit';
  
  // Audit
  static const auditLogsList = 'audit_logs:list';
  static const auditLogsExport = 'audit_logs:export';
  
  // Analytics
  static const analyticsView = 'analytics:view';
  static const analyticsExport = 'analytics:export';
  
  // Notifications
  static const notificationsSend = 'notifications:send';
  
  // System
  static const systemHealth = 'system:health';
  static const systemBackup = 'system:backup';
  static const systemConfig = 'system:config';
}
