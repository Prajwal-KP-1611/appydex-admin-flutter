class Vendor {
  Vendor({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.slug,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    Map<String, dynamic>? metadata,
    List<VendorDocument>? documents,
  }) : metadata = metadata ?? const {},
       documents = documents ?? const [];

  final int id;
  final int userId;
  final String companyName;
  final String slug;
  final String status; // pending, verified, rejected
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;
  final List<VendorDocument> documents;

  String get displayName => companyName;
  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  String? get contactEmail =>
      _stringFromMetadata(['contact_email', 'email', 'owner_email']);
  String? get contactPhone =>
      _stringFromMetadata(['contact_phone', 'phone', 'owner_phone']);
  String? get businessType =>
      metadata['business_type'] as String? ??
      metadata['entity_type'] as String?;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final metadata =
        (json['metadata'] as Map<String, dynamic>?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final documentsJson = json['documents'] as List<dynamic>? ?? const [];
    final documents = documentsJson
        .whereType<Map<String, dynamic>>()
        .map(VendorDocument.fromJson)
        .toList();

    final idValue = json['id'];
    final resolvedId = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '') ?? 0;

    final userIdValue = json['user_id'];
    final resolvedUserId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? '') ?? 0;

    final status =
        (json['status'] as String?) ??
        ((json['is_verified'] as bool? ?? false) ? 'verified' : 'pending');

    return Vendor(
      id: resolvedId,
      userId: resolvedUserId,
      companyName:
          json['company_name'] as String? ?? json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      status: status,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      metadata: metadata,
      documents: documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'slug': slug,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'metadata': metadata,
      if (documents.isNotEmpty)
        'documents': documents.map((doc) => doc.toJson()).toList(),
    };
  }

  Vendor copyWith({
    int? id,
    int? userId,
    String? companyName,
    String? slug,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    List<VendorDocument>? documents,
  }) {
    return Vendor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      documents: documents ?? this.documents,
    );
  }

  String? _stringFromMetadata(List<String> keys) {
    for (final key in keys) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

class VendorDocument {
  const VendorDocument({
    required this.id,
    required this.vendorId,
    required this.docType,
    required this.filePath,
    required this.verificationStatus,
    required this.uploadedAt,
  });

  final String id;
  final int vendorId;
  final String docType;
  final String filePath;
  final String verificationStatus;
  final DateTime uploadedAt;

  factory VendorDocument.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final vendorIdValue = json['vendor_id'];
    return VendorDocument(
      id: idValue?.toString() ?? '',
      vendorId: vendorIdValue is int
          ? vendorIdValue
          : int.tryParse(vendorIdValue?.toString() ?? '') ?? 0,
      docType: json['doc_type'] as String? ?? json['type'] as String? ?? '',
      filePath:
          json['file_path'] as String? ??
          json['url'] as String? ??
          json['file_name'] as String? ??
          '',
      verificationStatus:
          json['verification_status'] as String? ??
          json['status'] as String? ??
          'pending',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'doc_type': docType,
    'file_path': filePath,
    'verification_status': verificationStatus,
    'uploaded_at': uploadedAt.toIso8601String(),
  };

  String get displayType {
    switch (docType) {
      case 'business_license':
        return 'Business License';
      case 'tax_document':
        return 'Tax Document';
      case 'identity_proof':
        return 'Identity Proof';
      default:
        return docType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get fileName {
    if (filePath.isEmpty) return '';
    final segments = filePath.split('/');
    return segments.isNotEmpty ? segments.last : filePath;
  }
}
