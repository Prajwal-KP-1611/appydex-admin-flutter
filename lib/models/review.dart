/// Review model
/// Represents a user review for a vendor/service
class Review {
  const Review({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.createdAt,
    this.vendorName,
    this.userName,
    this.updatedAt,
    this.flagReason,
    this.adminNotes,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      userId: json['user_id'] as int,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      vendorName: json['vendor_name'] as String?,
      userName: json['user_name'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      flagReason: json['flag_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor_id': vendorId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        if (vendorName != null) 'vendor_name': vendorName,
        if (userName != null) 'user_name': userName,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (flagReason != null) 'flag_reason': flagReason,
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

  final int id;
  final int vendorId;
  final int userId;
  final int rating;
  final String comment;
  final String status; // 'pending', 'approved', 'hidden', 'removed'
  final DateTime createdAt;
  final String? vendorName;
  final String? userName;
  final DateTime? updatedAt;
  final String? flagReason;
  final String? adminNotes;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isHidden => status == 'hidden';
  bool get isRemoved => status == 'removed';
  bool get isFlagged => flagReason != null && flagReason!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
