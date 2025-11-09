/// Admin roles and permissions for RBAC system
/// Aligned with /api/v1/admin/roles/available
enum AdminRole {
  superAdmin('super_admin', 'Super Admin'),
  accountsAdmin('accounts_admin', 'Accounts Admin'),
  vendorAdmin('vendor_admin', 'Vendor Admin'),
  reviewsAdmin('reviews_admin', 'Reviews Admin'),
  supportAdmin('support_admin', 'Support Admin');

  const AdminRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static AdminRole fromString(String value) {
    return AdminRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => AdminRole.supportAdmin,
    );
  }

  /// Check if this role has permission for a specific action
  bool hasPermission(String module, String action) {
    // Super admin has all permissions
    if (this == AdminRole.superAdmin) return true;

    switch (this) {
      case AdminRole.vendorAdmin:
        return module == 'vendors' || module == 'services';
      case AdminRole.accountsAdmin:
        return module == 'subscriptions' ||
            module == 'payments' ||
            module == 'plans' ||
            module == 'users';
      case AdminRole.supportAdmin:
        return module == 'users' || module == 'support' || action == 'read';
      case AdminRole.reviewsAdmin:
        return module == 'reviews' || module == 'disputes';
      case AdminRole.superAdmin:
        return true;
    }
  }

  /// Check if this role can perform CRUD operations on a module
  bool canCreate(String module) => hasPermission(module, 'create');
  bool canRead(String module) => hasPermission(module, 'read');
  bool canUpdate(String module) => hasPermission(module, 'update');
  bool canDelete(String module) => hasPermission(module, 'delete');
}

/// Represents an authenticated admin session
class AdminSession {
  AdminSession({
    required this.accessToken,
    required this.refreshToken,
    required this.roles,
    required this.activeRole,
    this.adminId,
    this.email,
    this.expiresAt,
    this.permissions,
  });

  final String accessToken;
  final String refreshToken;
  final List<AdminRole> roles;
  final AdminRole activeRole;
  final String? adminId;
  final String? email;
  final DateTime? expiresAt;
  final List<String>? permissions; // Explicit permissions from backend

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    print('[AdminSession.fromJson] Input JSON keys: ${json.keys.join(", ")}');

    // Handle backend response format: { access, refresh, user: { roles, ... } }
    final userData = json['user'] as Map<String, dynamic>?;
    print(
      '[AdminSession.fromJson] User data: ${userData != null ? userData.keys.join(", ") : "null"}',
    );

    final rolesData =
        (userData?['roles'] ?? json['roles']) as List<dynamic>? ?? [];
    final roles = rolesData
        .map((r) => AdminRole.fromString(r.toString()))
        .toList();

    // Priority order for finding active role:
    // 1. json['active_role'] (root level)
    // 2. userData['active_role']
    // 3. First role from roles array if it contains super_admin
    // 4. First role from roles array
    // 5. Default to support_admin
    // Note: userData['role'] is often just "admin" and not helpful
    final activeRoleStr =
        (json['active_role'] ?? userData?['active_role']) as String?;
    print('[AdminSession.fromJson] activeRoleStr from JSON: $activeRoleStr');
    print('[AdminSession.fromJson] roles array: ${rolesData.join(", ")}');

    // Determine active role with a sane default:
    // 1) If backend provides active_role -> use it
    // 2) Else, if user has Super Admin among roles -> prefer Super Admin
    // 3) Else, fall back to first available role or Support Admin
    final activeRole = activeRoleStr != null
        ? AdminRole.fromString(activeRoleStr)
        : (roles.contains(AdminRole.superAdmin)
              ? AdminRole.superAdmin
              : (roles.isNotEmpty ? roles.first : AdminRole.supportAdmin));

    print(
      '[AdminSession.fromJson] Parsed roles: ${roles.map((r) => r.displayName).join(", ")}',
    );
    print('[AdminSession.fromJson] Active role: ${activeRole.displayName}');

    final email = (userData?['email'] ?? json['email']) as String?;
    print('[AdminSession.fromJson] Email: $email');

    // Parse explicit permissions array from backend (optional)
    final permissionsData =
        (userData?['permissions'] ?? json['permissions']) as List<dynamic>?;
    final permissions = permissionsData?.map((p) => p.toString()).toList();
    print(
      '[AdminSession.fromJson] Explicit permissions: ${permissions?.length ?? 0} items',
    );

    return AdminSession(
      accessToken: (json['access'] ?? json['access_token']) as String? ?? '',
      refreshToken: (json['refresh'] ?? json['refresh_token']) as String? ?? '',
      roles: roles,
      activeRole: activeRole,
      adminId: (userData?['id']?.toString() ?? json['admin_id']) as String?,
      email: email,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() => {
    'access': accessToken, // Match backend format
    'refresh': refreshToken, // Match backend format
    'access_token': accessToken, // Also include for compatibility
    'refresh_token': refreshToken, // Also include for compatibility
    'user': {
      'id': adminId,
      'email': email,
      'roles': roles.map((r) => r.value).toList(),
      'active_role': activeRole.value,
      'role': activeRole.value, // Also include for compatibility
      if (permissions != null) 'permissions': permissions,
    },
    'roles': roles.map((r) => r.value).toList(),
    'active_role': activeRole.value,
    'role': activeRole.value,
    'admin_id': adminId,
    'email': email,
    if (permissions != null) 'permissions': permissions,
    'expires_at': expiresAt?.toIso8601String(),
  };

  bool get isValid => accessToken.isNotEmpty;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  AdminSession copyWith({
    String? accessToken,
    String? refreshToken,
    List<AdminRole>? roles,
    AdminRole? activeRole,
    String? adminId,
    String? email,
    DateTime? expiresAt,
    List<String>? permissions,
  }) {
    return AdminSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      adminId: adminId ?? this.adminId,
      email: email ?? this.email,
      expiresAt: expiresAt ?? this.expiresAt,
      permissions: permissions ?? this.permissions,
    );
  }
}
