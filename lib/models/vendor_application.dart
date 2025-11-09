class VendorApplication {
  final int vendorId;
  final int? userId;
  final String? companyName;
  final String displayName; // NEW: Backend returns this
  final String registrationStatus; // pending|onboarding|verified|rejected
  final int registrationProgress; // 0-100
  final String registrationStep;
  final int onboardingScore; // NEW: Backend returns this
  final DateTime appliedAt;
  final Map<String, dynamic> applicationData;
  final VendorApplicationStats stats; // NEW: Backend returns this
  final List<String> incompleteFields;
  final List<VendorApplicationDocument> submittedDocuments;
  final List<String> missingDocuments;

  VendorApplication({
    required this.vendorId,
    this.userId,
    this.companyName,
    required this.displayName,
    required this.registrationStatus,
    required this.registrationProgress,
    required this.registrationStep,
    required this.onboardingScore,
    required this.appliedAt,
    required this.applicationData,
    required this.stats,
    required this.incompleteFields,
    required this.submittedDocuments,
    required this.missingDocuments,
  });

  factory VendorApplication.fromJson(Map<String, dynamic> json) {
    return VendorApplication(
      vendorId: json['vendor_id'] as int,
      userId: json['user_id'] as int?,
      companyName: json['company_name'] as String?,
      displayName: json['display_name'] as String? ?? '',
      registrationStatus: json['registration_status'] as String,
      registrationProgress: json['registration_progress'] as int? ?? 0,
      registrationStep: json['registration_step'] as String? ?? '',
      onboardingScore: json['onboarding_score'] as int? ?? 0,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      applicationData: json['application_data'] as Map<String, dynamic>? ?? {},
      stats: VendorApplicationStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? {},
      ),
      incompleteFields:
          (json['incomplete_fields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      submittedDocuments:
          (json['submitted_documents'] as List<dynamic>?)?.map((e) {
            return VendorApplicationDocument.fromJson(
              e as Map<String, dynamic>,
            );
          }).toList() ??
          [],
      missingDocuments:
          (json['missing_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      if (userId != null) 'user_id': userId,
      if (companyName != null) 'company_name': companyName,
      'display_name': displayName,
      'registration_status': registrationStatus,
      'registration_progress': registrationProgress,
      'registration_step': registrationStep,
      'onboarding_score': onboardingScore,
      'applied_at': appliedAt.toIso8601String(),
      'application_data': applicationData,
      'stats': stats.toJson(),
      'incomplete_fields': incompleteFields,
      'submitted_documents': submittedDocuments.map((e) => e.toJson()).toList(),
      'missing_documents': missingDocuments,
    };
  }

  bool get isPending => registrationStatus == 'pending';
  bool get isOnboarding => registrationStatus == 'onboarding';
  bool get isVerified => registrationStatus == 'verified';
  bool get isRejected => registrationStatus == 'rejected';
  bool get isComplete => registrationProgress == 100;
  bool get hasIncompleteFields => incompleteFields.isNotEmpty;
  bool get hasMissingDocuments => missingDocuments.isNotEmpty;
}

/// Stats returned by backend for vendor application
class VendorApplicationStats {
  final int servicesCount;
  final int bookingsCount;

  VendorApplicationStats({
    required this.servicesCount,
    required this.bookingsCount,
  });

  factory VendorApplicationStats.fromJson(Map<String, dynamic> json) {
    return VendorApplicationStats(
      servicesCount: json['services_count'] as int? ?? 0,
      bookingsCount: json['bookings_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'services_count': servicesCount, 'bookings_count': bookingsCount};
  }
}

class VendorApplicationDocument {
  final String type;
  final String status;
  final String? url;

  VendorApplicationDocument({
    required this.type,
    required this.status,
    this.url,
  });

  factory VendorApplicationDocument.fromJson(Map<String, dynamic> json) {
    return VendorApplicationDocument(
      type: json['type'] as String,
      status: json['status'] as String,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'status': status, if (url != null) 'url': url};
  }
}
