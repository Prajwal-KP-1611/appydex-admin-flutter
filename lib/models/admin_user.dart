import 'admin_role.dart';

/// Represents an admin user in the system
class AdminUser {
  AdminUser({
    required this.id,
    required this.email,
    required this.roles,
    this.name,
    this.createdAt,
  });

  final int id;
  final String email;
  final String? name;
  final List<AdminRole> roles;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final rolesData = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesData
        .map((r) => AdminRole.fromString(r.toString()))
        .toList();

    return AdminUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      roles: roles,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (name != null) 'name': name,
    'roles': roles.map((r) => r.value).toList(),
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  AdminUser copyWith({
    int? id,
    String? email,
    String? name,
    List<AdminRole>? roles,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if user has a specific role
  bool hasRole(AdminRole role) => roles.contains(role);

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<AdminRole> checkRoles) => roles.any(checkRoles.contains);

  /// Get display name (fallback to email if no full name)
  String get displayName => name ?? email;

  /// Check if user is super admin
  bool get isSuperAdmin => hasRole(AdminRole.superAdmin);
}

/// Request model for creating admin users
/// POST /api/v1/admin/accounts
/// { "email": "...", "password": "...", "role": "vendor_admin", "name": "..." }
class AdminUserRequest {
  AdminUserRequest({
    required this.email,
    required this.password,
    required this.role,
    this.name,
  });

  final String email;
  final String password;
  final String role; // Single role string: "super_admin", "vendor_admin", etc.
  final String? name;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role,
    if (name != null) 'name': name,
  };
}

/// Request model for updating admin users
/// PUT /api/v1/admin/accounts/{user_id}
/// All fields are optional: { "email": "...", "name": "...", "password": "..." }
/// Note: Role changes are done via /api/v1/admin/roles/assign and /revoke
class AdminUserUpdateRequest {
  AdminUserUpdateRequest({this.email, this.name, this.password});

  final String? email;
  final String? name;
  final String? password;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (email != null) json['email'] = email;
    if (name != null) json['name'] = name;
    if (password != null) json['password'] = password;
    return json;
  }

  /// Helper to create a request for email update only
  factory AdminUserUpdateRequest.email(String email) {
    return AdminUserUpdateRequest(email: email);
  }

  /// Helper to create a request for name update only
  factory AdminUserUpdateRequest.name(String name) {
    return AdminUserUpdateRequest(name: name);
  }

  /// Helper to create a request for password reset
  factory AdminUserUpdateRequest.password(String password) {
    return AdminUserUpdateRequest(password: password);
  }
}
