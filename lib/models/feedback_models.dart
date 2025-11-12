/// Feedback system models for admin panel
/// Based on API contract: FEEDBACK_SYSTEM_API.md
library;

enum FeedbackCategory {
  featureRequest('feature_request', 'Feature Request'),
  bugReport('bug_report', 'Bug Report'),
  improvement('improvement', 'Improvement'),
  general('general', 'General'),
  uxFeedback('ux_feedback', 'UX Feedback'),
  performance('performance', 'Performance');

  const FeedbackCategory(this.value, this.label);
  final String value;
  final String label;

  static FeedbackCategory fromString(String value) {
    return FeedbackCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackCategory.general,
    );
  }
}

enum FeedbackStatus {
  pending('pending', 'Pending'),
  underReview('under_review', 'Under Review'),
  planned('planned', 'Planned'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  declined('declined', 'Declined');

  const FeedbackStatus(this.value, this.label);
  final String value;
  final String label;

  static FeedbackStatus fromString(String value) {
    return FeedbackStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackStatus.pending,
    );
  }
}

enum FeedbackPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  const FeedbackPriority(this.value, this.label);
  final String value;
  final String label;

  static FeedbackPriority? fromString(String? value) {
    if (value == null) return null;
    return FeedbackPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackPriority.medium,
    );
  }
}

enum SubmitterType {
  user('user', 'User'),
  vendor('vendor', 'Vendor'),
  unknown('unknown', 'Unknown');

  const SubmitterType(this.value, this.label);
  final String value;
  final String label;

  static SubmitterType fromString(String value) {
    return SubmitterType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubmitterType.unknown,
    );
  }
}

class FeedbackItem {
  FeedbackItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    this.priority,
    required this.submitterName,
    required this.submitterType,
    this.submitterId,
    required this.votesCount,
    required this.commentsCount,
    this.adminResponse,
    this.respondedAt,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as int,
      category: FeedbackCategory.fromString(json['category'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      status: FeedbackStatus.fromString(json['status'] as String),
      priority: FeedbackPriority.fromString(json['priority'] as String?),
      submitterName: json['submitter_name'] as String,
      submitterType: SubmitterType.fromString(json['submitter_type'] as String),
      submitterId: json['submitter_id'] as int?,
      votesCount: json['votes_count'] as int,
      commentsCount: json['comments_count'] as int,
      adminResponse: json['admin_response'] as String?,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final FeedbackCategory category;
  final String title;
  final String description;
  final FeedbackStatus status;
  final FeedbackPriority? priority;
  final String submitterName;
  final SubmitterType submitterType;
  final int? submitterId;
  final int votesCount;
  final int commentsCount;
  final String? adminResponse;
  final DateTime? respondedAt;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.value,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority?.value,
      'submitter_name': submitterName,
      'submitter_type': submitterType.value,
      'submitter_id': submitterId,
      'votes_count': votesCount,
      'comments_count': commentsCount,
      'admin_response': adminResponse,
      'responded_at': respondedAt?.toIso8601String(),
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  FeedbackItem copyWith({
    int? id,
    FeedbackCategory? category,
    String? title,
    String? description,
    FeedbackStatus? status,
    FeedbackPriority? priority,
    String? submitterName,
    SubmitterType? submitterType,
    int? submitterId,
    int? votesCount,
    int? commentsCount,
    String? adminResponse,
    DateTime? respondedAt,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      submitterName: submitterName ?? this.submitterName,
      submitterType: submitterType ?? this.submitterType,
      submitterId: submitterId ?? this.submitterId,
      votesCount: votesCount ?? this.votesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      adminResponse: adminResponse ?? this.adminResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FeedbackComment {
  FeedbackComment({
    required this.id,
    required this.commenterName,
    required this.commenterType,
    required this.isAdmin,
    required this.content,
    required this.createdAt,
  });

  factory FeedbackComment.fromJson(Map<String, dynamic> json) {
    return FeedbackComment(
      id: json['id'] as int,
      commenterName: json['commenter_name'] as String,
      commenterType: json['commenter_type'] as String,
      isAdmin: json['is_admin'] as bool,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final String commenterName;
  final String commenterType;
  final bool isAdmin;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commenter_name': commenterName,
      'commenter_type': commenterType,
      'is_admin': isAdmin,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FeedbackDetails {
  FeedbackDetails({required this.feedback, required this.comments});

  factory FeedbackDetails.fromJson(Map<String, dynamic> json) {
    final commentsJson = json['comments'] as List<dynamic>? ?? [];
    return FeedbackDetails(
      feedback: FeedbackItem.fromJson(json),
      comments: commentsJson
          .map((c) => FeedbackComment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  final FeedbackItem feedback;
  final List<FeedbackComment> comments;
}

class FeedbackListResponse {
  FeedbackListResponse({required this.items, required this.pagination});

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    return FeedbackListResponse(
      items: itemsJson
          .map((item) => FeedbackItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  final List<FeedbackItem> items;
  final PaginationInfo pagination;
}

class PaginationInfo {
  PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
}

class FeedbackStats {
  FeedbackStats({
    required this.total,
    required this.pendingReview,
    required this.responseRate,
    this.avgResponseTimeHours,
    required this.byStatus,
    required this.byPriority,
    required this.byCategory,
    required this.recentSubmissions,
  });

  factory FeedbackStats.fromJson(Map<String, dynamic> json) {
    final recentJson = json['recent_submissions'] as List<dynamic>? ?? [];
    return FeedbackStats(
      total: json['total'] as int,
      pendingReview: json['pending_review'] as int,
      responseRate: (json['response_rate'] as num).toDouble(),
      avgResponseTimeHours: json['avg_response_time_hours'] != null
          ? (json['avg_response_time_hours'] as num).toDouble()
          : null,
      byStatus: Map<String, int>.from(json['by_status'] as Map),
      byPriority: Map<String, int>.from(json['by_priority'] as Map),
      byCategory: Map<String, int>.from(json['by_category'] as Map),
      recentSubmissions: recentJson
          .map((item) => RecentFeedback.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int total;
  final int pendingReview;
  final double responseRate;
  final double? avgResponseTimeHours;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;
  final Map<String, int> byCategory;
  final List<RecentFeedback> recentSubmissions;
}

class RecentFeedback {
  RecentFeedback({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.priority,
    required this.submitterType,
    required this.createdAt,
  });

  factory RecentFeedback.fromJson(Map<String, dynamic> json) {
    return RecentFeedback(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String?,
      submitterType: json['submitter_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final String title;
  final String category;
  final String status;
  final String? priority;
  final String submitterType;
  final DateTime createdAt;
}
