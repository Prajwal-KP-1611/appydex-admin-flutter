/// User session information for security monitoring
class UserSession {
  final String sessionId;
  final int userId;
  final bool isActive;
  final String? deviceType;
  final String? deviceName;
  final String? browser;
  final String ipAddress;
  final String? location;
  final DateTime lastActivity;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? terminatedAt;

  const UserSession({
    required this.sessionId,
    required this.userId,
    required this.isActive,
    this.deviceType,
    this.deviceName,
    this.browser,
    required this.ipAddress,
    this.location,
    required this.lastActivity,
    required this.createdAt,
    this.expiresAt,
    this.terminatedAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as int,
      isActive: json['is_active'] as bool? ?? false,
      deviceType: json['device_type'] as String?,
      deviceName: json['device_name'] as String?,
      browser: json['browser'] as String?,
      ipAddress: json['ip_address'] as String,
      location: json['location'] as String?,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      terminatedAt: json['terminated_at'] != null
          ? DateTime.parse(json['terminated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'is_active': isActive,
      'device_type': deviceType,
      'device_name': deviceName,
      'browser': browser,
      'ip_address': ipAddress,
      'location': location,
      'last_activity': lastActivity.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'terminated_at': terminatedAt?.toIso8601String(),
    };
  }

  /// Get device display name
  String get deviceDisplay {
    if (deviceName != null) return deviceName!;
    if (deviceType != null) return deviceType!;
    return 'Unknown Device';
  }

  /// Get duration since last activity
  String get lastActivityDisplay {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Check if session is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get session duration
  Duration get sessionDuration {
    final endTime = terminatedAt ?? DateTime.now();
    return endTime.difference(createdAt);
  }
}

/// User sessions response containing active and recent sessions
class UserSessions {
  final List<UserSession> activeSessions;
  final List<RecentLogin> recentLogins;

  const UserSessions({
    required this.activeSessions,
    required this.recentLogins,
  });

  factory UserSessions.fromJson(Map<String, dynamic> json) {
    return UserSessions(
      activeSessions:
          (json['active_sessions'] as List<dynamic>?)
              ?.map((e) => UserSession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentLogins:
          (json['recent_logins'] as List<dynamic>?)
              ?.map((e) => RecentLogin.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_sessions': activeSessions.map((e) => e.toJson()).toList(),
      'recent_logins': recentLogins.map((e) => e.toJson()).toList(),
    };
  }

  /// Get total active session count
  int get activeSessionCount => activeSessions.length;

  /// Check if user has multiple active sessions
  bool get hasMultipleSessions => activeSessions.length > 1;
}

/// Recent login entry
class RecentLogin {
  final DateTime loginAt;
  final String ipAddress;
  final String? deviceType;
  final String? location;
  final bool success;

  const RecentLogin({
    required this.loginAt,
    required this.ipAddress,
    this.deviceType,
    this.location,
    required this.success,
  });

  factory RecentLogin.fromJson(Map<String, dynamic> json) {
    return RecentLogin(
      loginAt: DateTime.parse(json['login_at'] as String),
      ipAddress: json['ip_address'] as String,
      deviceType: json['device_type'] as String?,
      location: json['location'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login_at': loginAt.toIso8601String(),
      'ip_address': ipAddress,
      'device_type': deviceType,
      'location': location,
      'success': success,
    };
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(loginAt);

    if (difference.inDays > 7) {
      return '${loginAt.day}/${loginAt.month}/${loginAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
