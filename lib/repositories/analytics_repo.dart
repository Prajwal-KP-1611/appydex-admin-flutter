import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import 'admin_exceptions.dart';

class TopSearchItem {
  const TopSearchItem({required this.query, required this.count});
  final String query;
  final int count;
  factory TopSearchItem.fromJson(Map<String, dynamic> json) => TopSearchItem(
    query: json['query'] as String? ?? '',
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

class CtrPoint {
  const CtrPoint({
    required this.date,
    required this.clicks,
    required this.impressions,
  });
  final DateTime date;
  final int clicks;
  final int impressions;
  double get ctr => impressions == 0 ? 0 : (clicks / impressions) * 100;
  factory CtrPoint.fromJson(Map<String, dynamic> json) => CtrPoint(
    date: DateTime.parse(json['date'] as String),
    clicks: (json['clicks'] as num?)?.toInt() ?? 0,
    impressions: (json['impressions'] as num?)?.toInt() ?? 0,
  );
}

/// Repository for analytics dashboard data
/// Base Path: /api/v1/admin/analytics
class AnalyticsRepository {
  AnalyticsRepository(this._client);
  final ApiClient _client;

  Future<List<TopSearchItem>> fetchTopSearches({
    required DateTime start,
    required DateTime end,
    int limit = 10,
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/top-searches',
        queryParameters: {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
          'limit': limit,
        },
      );
      final data = response.data?['items'] as List<dynamic>? ?? const [];
      return data
          .map((e) => TopSearchItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/analytics/top-searches');
      }
      rethrow;
    }
  }

  Future<List<CtrPoint>> fetchCtrSeries({
    required DateTime start,
    required DateTime end,
    String granularity = 'day',
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/ctr',
        queryParameters: {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
          'granularity': granularity,
        },
      );
      final data = response.data?['points'] as List<dynamic>? ?? const [];
      return data
          .map((e) => CtrPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/analytics/ctr');
      }
      rethrow;
    }
  }

  Future<String> requestExport({
    required DateTime start,
    required DateTime end,
    String format = 'csv',
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/export',
        method: 'POST',
        data: {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
          'format': format,
        },
      );
      final jobId = response.data?['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        throw Exception('Missing job_id in export response');
      }
      return jobId;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/analytics/export');
      }
      rethrow;
    }
  }

  /// Fetch booking analytics
  /// GET /api/v1/admin/analytics/bookings
  ///
  /// Query Parameters:
  /// - from: Start date (ISO 8601)
  /// - to: End date (ISO 8601)
  /// - status: Filter by status
  /// - group_by: Group by day, week, or month (default: day)
  Future<Map<String, dynamic>> fetchBookingAnalytics({
    required DateTime start,
    required DateTime end,
    String? status,
    String groupBy = 'day',
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/bookings',
        queryParameters: {
          'from': start.toIso8601String(),
          'to': end.toIso8601String(),
          if (status != null && status.isNotEmpty) 'status': status,
          'group_by': groupBy,
        },
      );
      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/analytics/bookings');
      }
      rethrow;
    }
  }

  /// Fetch revenue analytics
  /// GET /api/v1/admin/analytics/revenue
  ///
  /// Query Parameters:
  /// - from: Start date (ISO 8601)
  /// - to: End date (ISO 8601)
  /// - group_by: Group by day, week, or month (default: day)
  Future<Map<String, dynamic>> fetchRevenueAnalytics({
    required DateTime start,
    required DateTime end,
    String groupBy = 'day',
  }) async {
    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/analytics/revenue',
        queryParameters: {
          'from': start.toIso8601String(),
          'to': end.toIso8601String(),
          'group_by': groupBy,
        },
      );
      return response.data ?? {};
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/analytics/revenue');
      }
      rethrow;
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnalyticsRepository(client);
});
