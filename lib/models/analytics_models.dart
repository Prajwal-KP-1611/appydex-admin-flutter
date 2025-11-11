/// Model for platform hits data
/// Corresponds to GET /api/v1/admin/analytics/platform-hits
class PlatformHits {
  final String platform;
  final int count;

  const PlatformHits({required this.platform, required this.count});

  factory PlatformHits.fromJson(Map<String, dynamic> json) {
    return PlatformHits(
      platform: json['platform'] as String,
      count: (json['count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {'platform': platform, 'count': count};
}

/// Response wrapper for platform hits
class PlatformHitsResponse {
  final List<PlatformHits> platformHits;

  const PlatformHitsResponse({required this.platformHits});

  factory PlatformHitsResponse.fromJson(Map<String, dynamic> json) {
    final hitsJson = json['platform_hits'] as List<dynamic>? ?? [];
    return PlatformHitsResponse(
      platformHits: hitsJson
          .map((e) => PlatformHits.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'platform_hits': platformHits.map((e) => e.toJson()).toList(),
  };
}

/// Model for active users count
/// Corresponds to GET /api/v1/admin/analytics/active-users
class ActiveUsersCount {
  final int activeUsers;

  const ActiveUsersCount({required this.activeUsers});

  factory ActiveUsersCount.fromJson(Map<String, dynamic> json) {
    return ActiveUsersCount(
      activeUsers: (json['active_users'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'active_users': activeUsers};
}
