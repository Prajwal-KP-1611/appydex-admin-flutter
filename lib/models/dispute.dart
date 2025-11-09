import 'dispute_message.dart';

/// Dispute model for end-user dispute resolution system
class Dispute {
  final int id;
  final String disputeReference;
  final DisputeType type;
  final String? category;
  final DisputeStatus status;
  final DisputePriority priority;
  final String subject;
  final String description;

  // Related entities
  final int userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final int? bookingId;
  final String? bookingReference;
  final int? vendorId;
  final String? vendorName;

  // Financial details
  final int amountDisputed; // in paise
  final bool refundRequested;
  final int refundAmount; // in paise
  final bool refundProcessed;
  final String? refundTransactionId;

  // Evidence
  final List<DisputeEvidence> evidence;

  // Vendor response
  final String? vendorResponse;
  final DateTime? vendorRespondedAt;

  // Assignment and tracking
  final int? assignedTo;
  final String? assignedToName;
  final DateTime? assignedAt;
  final DateTime? resolutionDeadline;

  // Resolution
  final String? adminNotes;
  final String? resolution;
  final DisputeResolutionType? resolutionType;
  final String? resolutionDetails;
  final DateTime? resolvedAt;
  final int? resolvedBy;
  final String? resolvedByName;

  // Messages
  final List<DisputeMessage> messages;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Dispute({
    required this.id,
    required this.disputeReference,
    required this.type,
    this.category,
    required this.status,
    required this.priority,
    required this.subject,
    required this.description,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.bookingId,
    this.bookingReference,
    this.vendorId,
    this.vendorName,
    required this.amountDisputed,
    required this.refundRequested,
    required this.refundAmount,
    required this.refundProcessed,
    this.refundTransactionId,
    required this.evidence,
    this.vendorResponse,
    this.vendorRespondedAt,
    this.assignedTo,
    this.assignedToName,
    this.assignedAt,
    this.resolutionDeadline,
    this.adminNotes,
    this.resolution,
    this.resolutionType,
    this.resolutionDetails,
    this.resolvedAt,
    this.resolvedBy,
    this.resolvedByName,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] as int,
      disputeReference: json['dispute_reference'] as String,
      type: DisputeType.fromString(json['type'] as String),
      category: json['category'] as String?,
      status: DisputeStatus.fromString(json['status'] as String),
      priority: DisputePriority.fromString(json['priority'] as String),
      subject: json['subject'] as String,
      description: json['description'] as String,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userEmail: json['user_email'] as String,
      userPhone: json['user_phone'] as String,
      bookingId: json['booking_id'] as int?,
      bookingReference: json['booking_reference'] as String?,
      vendorId: json['vendor_id'] as int?,
      vendorName: json['vendor_name'] as String?,
      amountDisputed: json['amount_disputed'] as int? ?? 0,
      refundRequested: json['refund_requested'] as bool? ?? false,
      refundAmount: json['refund_amount'] as int? ?? 0,
      refundProcessed: json['refund_processed'] as bool? ?? false,
      refundTransactionId: json['refund_transaction_id'] as String?,
      evidence:
          (json['evidence'] as List<dynamic>?)
              ?.map((e) => DisputeEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vendorResponse: json['vendor_response'] as String?,
      vendorRespondedAt: json['vendor_responded_at'] != null
          ? DateTime.parse(json['vendor_responded_at'] as String)
          : null,
      assignedTo: json['assigned_to'] as int?,
      assignedToName: json['assigned_to_name'] as String?,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      resolutionDeadline: json['resolution_deadline'] != null
          ? DateTime.parse(json['resolution_deadline'] as String)
          : null,
      adminNotes: json['admin_notes'] as String?,
      resolution: json['resolution'] as String?,
      resolutionType: json['resolution_type'] != null
          ? DisputeResolutionType.fromString(json['resolution_type'] as String)
          : null,
      resolutionDetails: json['resolution_details'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as int?,
      resolvedByName: json['resolved_by_name'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => DisputeMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dispute_reference': disputeReference,
      'type': type.value,
      'category': category,
      'status': status.value,
      'priority': priority.value,
      'subject': subject,
      'description': description,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'booking_id': bookingId,
      'booking_reference': bookingReference,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'amount_disputed': amountDisputed,
      'refund_requested': refundRequested,
      'refund_amount': refundAmount,
      'refund_processed': refundProcessed,
      'refund_transaction_id': refundTransactionId,
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'vendor_response': vendorResponse,
      'vendor_responded_at': vendorRespondedAt?.toIso8601String(),
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'assigned_at': assignedAt?.toIso8601String(),
      'resolution_deadline': resolutionDeadline?.toIso8601String(),
      'admin_notes': adminNotes,
      'resolution': resolution,
      'resolution_type': resolutionType?.value,
      'resolution_details': resolutionDetails,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'resolved_by_name': resolvedByName,
      'messages': messages.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if dispute is overdue
  bool get isOverdue {
    if (resolutionDeadline == null) return false;
    return DateTime.now().isAfter(resolutionDeadline!) &&
        status != DisputeStatus.resolved &&
        status != DisputeStatus.closed;
  }

  /// Check if dispute is assigned
  bool get isAssigned => assignedTo != null;

  /// Check if vendor has responded
  bool get hasVendorResponse => vendorResponse != null;

  /// Get hours until deadline
  int? get hoursUntilDeadline {
    if (resolutionDeadline == null) return null;
    return resolutionDeadline!.difference(DateTime.now()).inHours;
  }

  /// Format amount for display
  String get amountDisputedFormatted {
    return '₹${(amountDisputed / 100).toStringAsFixed(2)}';
  }

  Dispute copyWith({
    int? id,
    String? disputeReference,
    DisputeType? type,
    String? category,
    DisputeStatus? status,
    DisputePriority? priority,
    String? subject,
    String? description,
    int? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    int? bookingId,
    String? bookingReference,
    int? vendorId,
    String? vendorName,
    int? amountDisputed,
    bool? refundRequested,
    int? refundAmount,
    bool? refundProcessed,
    String? refundTransactionId,
    List<DisputeEvidence>? evidence,
    String? vendorResponse,
    DateTime? vendorRespondedAt,
    int? assignedTo,
    String? assignedToName,
    DateTime? assignedAt,
    DateTime? resolutionDeadline,
    String? adminNotes,
    String? resolution,
    DisputeResolutionType? resolutionType,
    String? resolutionDetails,
    DateTime? resolvedAt,
    int? resolvedBy,
    String? resolvedByName,
    List<DisputeMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dispute(
      id: id ?? this.id,
      disputeReference: disputeReference ?? this.disputeReference,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      bookingId: bookingId ?? this.bookingId,
      bookingReference: bookingReference ?? this.bookingReference,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      amountDisputed: amountDisputed ?? this.amountDisputed,
      refundRequested: refundRequested ?? this.refundRequested,
      refundAmount: refundAmount ?? this.refundAmount,
      refundProcessed: refundProcessed ?? this.refundProcessed,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
      evidence: evidence ?? this.evidence,
      vendorResponse: vendorResponse ?? this.vendorResponse,
      vendorRespondedAt: vendorRespondedAt ?? this.vendorRespondedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedAt: assignedAt ?? this.assignedAt,
      resolutionDeadline: resolutionDeadline ?? this.resolutionDeadline,
      adminNotes: adminNotes ?? this.adminNotes,
      resolution: resolution ?? this.resolution,
      resolutionType: resolutionType ?? this.resolutionType,
      resolutionDetails: resolutionDetails ?? this.resolutionDetails,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedByName: resolvedByName ?? this.resolvedByName,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dispute evidence attachment
class DisputeEvidence {
  final String type; // image, document, screenshot
  final String url;
  final String? description;

  const DisputeEvidence({
    required this.type,
    required this.url,
    this.description,
  });

  factory DisputeEvidence.fromJson(Map<String, dynamic> json) {
    return DisputeEvidence(
      type: json['type'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'url': url, 'description': description};
  }
}

/// Dispute type enum
enum DisputeType {
  bookingIssue('booking_issue', 'Booking Issue'),
  paymentIssue('payment_issue', 'Payment Issue'),
  serviceQuality('service_quality', 'Service Quality'),
  vendorBehavior('vendor_behavior', 'Vendor Behavior'),
  refundRequest('refund_request', 'Refund Request'),
  other('other', 'Other');

  final String value;
  final String label;

  const DisputeType(this.value, this.label);

  static DisputeType fromString(String value) {
    return DisputeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DisputeType.other,
    );
  }
}

/// Dispute status enum
enum DisputeStatus {
  open('open', 'Open'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved'),
  closed('closed', 'Closed'),
  rejected('rejected', 'Rejected');

  final String value;
  final String label;

  const DisputeStatus(this.value, this.label);

  static DisputeStatus fromString(String value) {
    return DisputeStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DisputeStatus.open,
    );
  }
}

/// Dispute priority enum
enum DisputePriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  final String value;
  final String label;

  const DisputePriority(this.value, this.label);

  static DisputePriority fromString(String value) {
    return DisputePriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DisputePriority.medium,
    );
  }
}

/// Dispute resolution type enum
enum DisputeResolutionType {
  fullRefund('full_refund', 'Full Refund'),
  partialRefund('partial_refund', 'Partial Refund'),
  noRefund('no_refund', 'No Refund'),
  serviceRedo('service_redo', 'Service Redo'),
  compensation('compensation', 'Compensation'),
  other('other', 'Other');

  final String value;
  final String label;

  const DisputeResolutionType(this.value, this.label);

  static DisputeResolutionType fromString(String value) {
    return DisputeResolutionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DisputeResolutionType.other,
    );
  }
}

/// Dispute summary for list views
class DisputeSummary {
  final int totalDisputes;
  final int open;
  final int inProgress;
  final int resolved;
  final double avgResolutionTimeHours;
  final double userWinRate;

  const DisputeSummary({
    required this.totalDisputes,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.avgResolutionTimeHours,
    required this.userWinRate,
  });

  factory DisputeSummary.fromJson(Map<String, dynamic> json) {
    return DisputeSummary(
      totalDisputes: json['total_disputes'] as int? ?? 0,
      open: json['open'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      resolved: json['resolved'] as int? ?? 0,
      avgResolutionTimeHours:
          (json['avg_resolution_time_hours'] as num?)?.toDouble() ?? 0.0,
      userWinRate: (json['user_win_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_disputes': totalDisputes,
      'open': open,
      'in_progress': inProgress,
      'resolved': resolved,
      'avg_resolution_time_hours': avgResolutionTimeHours,
      'user_win_rate': userWinRate,
    };
  }
}
