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
  });

  final String accessToken;
  final String refreshToken;
  final List<AdminRole> roles;
  final AdminRole activeRole;
  final String? adminId;
  final String? email;
  final DateTime? expiresAt;

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    // Handle backend response format: { access, refresh, user: { roles, ... } }
    final userData = json['user'] as Map<String, dynamic>?;
    final rolesData =
        (userData?['roles'] ?? json['roles']) as List<dynamic>? ?? [];
    final roles = rolesData
        .map((r) => AdminRole.fromString(r.toString()))
        .toList();

    final activeRoleStr =
        (userData?['active_role'] ??
                userData?['role'] ??
                json['active_role'] ??
                json['role'])
            as String?;
    final activeRole = activeRoleStr != null
        ? AdminRole.fromString(activeRoleStr)
        : (roles.isNotEmpty ? roles.first : AdminRole.supportAdmin);

    return AdminSession(
      accessToken: (json['access'] ?? json['access_token']) as String? ?? '',
      refreshToken: (json['refresh'] ?? json['refresh_token']) as String? ?? '',
      roles: roles,
      activeRole: activeRole,
      adminId: (userData?['id']?.toString() ?? json['admin_id']) as String?,
      email: (userData?['email'] ?? json['email']) as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'roles': roles.map((r) => r.value).toList(),
    'active_role': activeRole.value,
    'admin_id': adminId,
    'email': email,
    'expires_at': expiresAt?.toIso8601String(),
  };

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

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
  }) {
    return AdminSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      adminId: adminId ?? this.adminId,
      email: email ?? this.email,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
