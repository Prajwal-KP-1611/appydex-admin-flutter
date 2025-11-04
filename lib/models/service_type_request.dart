import '../models/service_type.dart';

/// Service Type Request model
/// Represents vendor requests for new service categories
class ServiceTypeRequest {
  const ServiceTypeRequest({
    required this.id,
    required this.vendorId,
    required this.requestedName,
    required this.status,
    required this.createdAt,
    this.vendorName,
    this.requestedDescription,
    this.justification,
    this.reviewNotes,
    this.reviewedBy,
    this.reviewedAt,
  });

  final int id;
  final int vendorId;
  final String? vendorName;
  final String requestedName;
  final String? requestedDescription;
  final String? justification;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewNotes;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory ServiceTypeRequest.fromJson(Map<String, dynamic> json) {
    return ServiceTypeRequest(
      id: json['id'] as int? ?? 0,
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String?,
      requestedName: json['requested_name'] as String? ?? '',
      requestedDescription: json['requested_description'] as String?,
      justification: json['justification'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewNotes: json['review_notes'] as String?,
      reviewedBy: json['reviewed_by'] as int?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      if (vendorName != null) 'vendor_name': vendorName,
      'requested_name': requestedName,
      if (requestedDescription != null)
        'requested_description': requestedDescription,
      if (justification != null) 'justification': justification,
      'status': status,
      if (reviewNotes != null) 'review_notes': reviewNotes,
      if (reviewedBy != null) 'reviewed_by': reviewedBy,
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

/// Overdue request details for SLA monitoring
class OverdueRequest {
  const OverdueRequest({
    required this.id,
    required this.requestedName,
    required this.vendorId,
    required this.ageHours,
    required this.createdAt,
  });

  final int id;
  final String requestedName;
  final int vendorId;
  final double ageHours;
  final DateTime createdAt;

  factory OverdueRequest.fromJson(Map<String, dynamic> json) {
    return OverdueRequest(
      id: json['id'] as int? ?? 0,
      requestedName: json['requested_name'] as String? ?? '',
      vendorId: json['vendor_id'] as int? ?? 0,
      ageHours: (json['age_hours'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// SLA statistics for service type requests
/// GET /api/v1/admin/service-type-requests/stats
class ServiceTypeRequestStats {
  const ServiceTypeRequestStats({
    required this.pendingTotal,
    required this.pendingUnder24h,
    required this.pending24To48h,
    required this.pendingOver48h,
    required this.overdueRequests,
    required this.approvedThisMonth,
    required this.rejectedThisMonth,
    required this.avgReviewTimeHours,
    required this.slaComplianceRate,
    required this.monthStart,
  });

  final int pendingTotal;
  final int pendingUnder24h;
  final int pending24To48h;
  final int pendingOver48h;
  final List<OverdueRequest> overdueRequests;
  final int approvedThisMonth;
  final int rejectedThisMonth;
  final double avgReviewTimeHours;
  final double slaComplianceRate;
  final DateTime monthStart;

  factory ServiceTypeRequestStats.fromJson(Map<String, dynamic> json) {
    return ServiceTypeRequestStats(
      pendingTotal: json['pending_total'] as int? ?? 0,
      pendingUnder24h: json['pending_under_24h'] as int? ?? 0,
      pending24To48h: json['pending_24_48h'] as int? ?? 0,
      pendingOver48h: json['pending_over_48h'] as int? ?? 0,
      overdueRequests:
          (json['overdue_requests'] as List<dynamic>?)
              ?.map((e) => OverdueRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      approvedThisMonth: json['approved_this_month'] as int? ?? 0,
      rejectedThisMonth: json['rejected_this_month'] as int? ?? 0,
      avgReviewTimeHours:
          (json['avg_review_time_hours'] as num?)?.toDouble() ?? 0.0,
      slaComplianceRate:
          (json['sla_compliance_rate'] as num?)?.toDouble() ?? 0.0,
      monthStart: json['month_start'] != null
          ? DateTime.tryParse(json['month_start'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get hasSlaViolations => pendingOver48h > 0;
  String get complianceRateDisplay =>
      '${slaComplianceRate.toStringAsFixed(1)}%';
}

/// Result of service type request approval
class ServiceTypeRequestApprovalResult {
  const ServiceTypeRequestApprovalResult({
    required this.requestId,
    required this.status,
    this.createdServiceType,
    this.reviewNotes,
    this.reviewedBy,
    this.message,
  });

  final int requestId;
  final String status;
  final ServiceType? createdServiceType;
  final String? reviewNotes;
  final int? reviewedBy;
  final String? message;

  factory ServiceTypeRequestApprovalResult.fromJson(Map<String, dynamic> json) {
    return ServiceTypeRequestApprovalResult(
      requestId: json['request_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      createdServiceType: json['created_service_type'] != null
          ? ServiceType.fromJson(
              json['created_service_type'] as Map<String, dynamic>,
            )
          : null,
      reviewNotes: json['review_notes'] as String?,
      reviewedBy: json['reviewed_by'] as int?,
      message: json['message'] as String?,
    );
  }
}

/// Result of service type request rejection
class ServiceTypeRequestRejectionResult {
  const ServiceTypeRequestRejectionResult({
    required this.requestId,
    required this.status,
    this.reviewNotes,
    this.reviewedBy,
    this.message,
  });

  final int requestId;
  final String status;
  final String? reviewNotes;
  final int? reviewedBy;
  final String? message;

  factory ServiceTypeRequestRejectionResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceTypeRequestRejectionResult(
      requestId: json['request_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      reviewNotes: json['review_notes'] as String?,
      reviewedBy: json['reviewed_by'] as int?,
      message: json['message'] as String?,
    );
  }
}
