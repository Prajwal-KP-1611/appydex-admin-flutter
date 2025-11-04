/// Audit Log model
/// Tracks all admin actions for accountability and debugging
class AuditLog {
  const AuditLog({
    required this.id,
    required this.actorUserId,
    required this.action,
    required this.resourceType,
    required this.createdAt,
    this.actorName,
    this.actorRole,
    this.resourceId,
    this.diff,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    this.traceId,
  });

  final String id;
  final int actorUserId;
  final String? actorName;
  final String? actorRole;
  final String action; // e.g., 'vendor_verification_approved'
  final String resourceType; // e.g., 'vendor', 'service', 'subscription'
  final int? resourceId;
  final Map<String, dynamic>? diff; // before/after state
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final String? traceId;
  final DateTime createdAt;

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id']?.toString() ?? '',
      actorUserId: json['actor_user_id'] as int? ?? 0,
      actorName: json['actor_name'] as String?,
      actorRole: json['actor_role'] as String?,
      action: json['action'] as String? ?? '',
      resourceType: json['resource_type'] as String? ?? '',
      resourceId: json['resource_id'] as int?,
      diff: json['diff'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      traceId: json['trace_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_user_id': actorUserId,
      if (actorName != null) 'actor_name': actorName,
      if (actorRole != null) 'actor_role': actorRole,
      'action': action,
      'resource_type': resourceType,
      if (resourceId != null) 'resource_id': resourceId,
      if (diff != null) 'diff': diff,
      if (metadata != null) 'metadata': metadata,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (userAgent != null) 'user_agent': userAgent,
      if (traceId != null) 'trace_id': traceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get actionDisplay {
    return action
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

/// Audit log details with full resource information
class AuditLogDetails extends AuditLog {
  const AuditLogDetails({
    required super.id,
    required super.actorUserId,
    required super.action,
    required super.resourceType,
    required super.createdAt,
    super.actorName,
    super.actorRole,
    super.resourceId,
    super.diff,
    super.metadata,
    super.ipAddress,
    super.userAgent,
    super.traceId,
    this.resourceDetails,
  });

  final Map<String, dynamic>? resourceDetails;

  factory AuditLogDetails.fromJson(Map<String, dynamic> json) {
    return AuditLogDetails(
      id: json['id']?.toString() ?? '',
      actorUserId: json['actor_user_id'] as int? ?? 0,
      actorName: json['actor_name'] as String?,
      actorRole: json['actor_role'] as String?,
      action: json['action'] as String? ?? '',
      resourceType: json['resource_type'] as String? ?? '',
      resourceId: json['resource_id'] as int?,
      diff: json['diff'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      traceId: json['trace_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      resourceDetails: json['resource_details'] as Map<String, dynamic>?,
    );
  }
}
