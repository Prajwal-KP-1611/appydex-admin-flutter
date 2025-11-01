class AuditEvent {
  AuditEvent({
    required this.id,
    required this.adminIdentifier,
    required this.action,
    required this.subjectType,
    required this.subjectId,
    required this.createdAt,
    this.payload,
  });

  final int id;
  final String adminIdentifier;
  final String action;
  final String subjectType;
  final String subjectId;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as int,
      adminIdentifier: json['admin_identifier'] as String? ?? 'unknown',
      action: json['action'] as String? ?? 'unknown',
      subjectType: json['subject_type'] as String? ?? 'unknown',
      subjectId: '${json['subject_id'] ?? ''}',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_identifier': adminIdentifier,
      'action': action,
      'subject_type': subjectType,
      'subject_id': subjectId,
      'created_at': createdAt.toIso8601String(),
      'payload': payload,
    };
  }
}
