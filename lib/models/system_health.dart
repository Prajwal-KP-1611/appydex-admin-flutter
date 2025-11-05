import 'package:flutter/foundation.dart';

/// System health and ephemeral data statistics
/// Monitors short-lived data retention and cleanup
@immutable
class EphemeralStats {
  const EphemeralStats({
    required this.idempotencyKeys,
    required this.webhookEvents,
    required this.refreshTokens,
  });

  final DataTypeStats idempotencyKeys;
  final DataTypeStats webhookEvents;
  final RefreshTokenStats refreshTokens;

  factory EphemeralStats.fromJson(Map<String, dynamic> json) {
    return EphemeralStats(
      idempotencyKeys: DataTypeStats.fromJson(
        json['idempotency_keys'] as Map<String, dynamic>? ?? {},
      ),
      webhookEvents: DataTypeStats.fromJson(
        json['webhook_events'] as Map<String, dynamic>? ?? {},
      ),
      refreshTokens: RefreshTokenStats.fromJson(
        json['refresh_tokens'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idempotency_keys': idempotencyKeys.toJson(),
      'webhook_events': webhookEvents.toJson(),
      'refresh_tokens': refreshTokens.toJson(),
    };
  }
}

/// Statistics for a data type
@immutable
class DataTypeStats {
  const DataTypeStats({required this.total, required this.last7Days});

  final int total;
  final int last7Days;

  factory DataTypeStats.fromJson(Map<String, dynamic> json) {
    return DataTypeStats(
      total: json['total'] as int? ?? 0,
      last7Days: json['last_7_days'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'last_7_days': last7Days};
  }
}

/// Statistics for refresh tokens
@immutable
class RefreshTokenStats {
  const RefreshTokenStats({
    required this.total,
    required this.active,
    required this.expired,
  });

  final int total;
  final int active;
  final int expired;

  factory RefreshTokenStats.fromJson(Map<String, dynamic> json) {
    return RefreshTokenStats(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      expired: json['expired'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'active': active, 'expired': expired};
  }
}
