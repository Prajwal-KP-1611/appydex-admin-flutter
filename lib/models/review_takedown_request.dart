/// Review takedown request model
///
/// Represents a vendor's request to remove or hide a review.
class ReviewTakedownRequest {
  const ReviewTakedownRequest({
    required this.id,
    required this.reviewId,
    required this.vendorId,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.review,
    this.vendorName,
    this.details,
    this.evidenceUrls,
    this.submittedById,
    this.adminNotes,
    this.reviewedById,
    this.reviewedAt,
  });

  final int id;
  final int reviewId;
  final int vendorId;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;

  // Optional enriched data
  final Map<String, dynamic>? review;
  final String? vendorName;
  final String? details;
  final List<String>? evidenceUrls;
  final int? submittedById;
  final String? adminNotes;
  final int? reviewedById;
  final DateTime? reviewedAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory ReviewTakedownRequest.fromJson(Map<String, dynamic> json) {
    return ReviewTakedownRequest(
      id: (json['id'] as num).toInt(),
      reviewId: (json['review_id'] as num).toInt(),
      vendorId: (json['vendor_id'] as num).toInt(),
      reason: json['reason'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      review: json['review'] as Map<String, dynamic>?,
      vendorName: json['vendor_name'] as String?,
      details: json['details'] as String?,
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      submittedById: (json['submitted_by_id'] as num?)?.toInt(),
      adminNotes: json['admin_notes'] as String?,
      reviewedById: (json['reviewed_by_id'] as num?)?.toInt(),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'vendor_id': vendorId,
      'reason': reason,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      if (review != null) 'review': review,
      if (vendorName != null) 'vendor_name': vendorName,
      if (details != null) 'details': details,
      if (evidenceUrls != null) 'evidence_urls': evidenceUrls,
      if (submittedById != null) 'submitted_by_id': submittedById,
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (reviewedById != null) 'reviewed_by_id': reviewedById,
      if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
    };
  }
}

/// Takedown request resolution decision
enum TakedownDecision {
  approve,
  reject;

  String toJson() => name;
}

/// Action to take on review when approving takedown
enum TakedownAction {
  hide,
  remove;

  String toJson() => name;
}

/// Request body for resolving a takedown request
class ResolveTakedownRequest {
  const ResolveTakedownRequest({
    required this.decision,
    this.actionIfApprove,
    this.adminNotes,
    this.notifyVendor = true,
    this.notifyReviewer = false,
  });

  final TakedownDecision decision;
  final TakedownAction? actionIfApprove; // Required if decision is approve
  final String? adminNotes;
  final bool notifyVendor;
  final bool notifyReviewer;

  Map<String, dynamic> toJson() {
    return {
      'decision': decision.toJson(),
      if (actionIfApprove != null)
        'action_if_approve': actionIfApprove!.toJson(),
      if (adminNotes != null) 'admin_notes': adminNotes,
      'notify_vendor': notifyVendor,
      'notify_reviewer': notifyReviewer,
    };
  }
}
