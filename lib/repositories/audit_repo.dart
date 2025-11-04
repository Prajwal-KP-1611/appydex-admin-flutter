import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../core/pagination.dart';
import '../models/audit_event.dart';
import 'admin_exceptions.dart';

class AuditRepository {
  AuditRepository(this._client);

  final ApiClient _client;

  Future<Pagination<AuditEvent>> list({
    String? action,
    String? adminIdentifier,
    String? subjectType,
    String? subjectId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 50,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (action != null && action.isNotEmpty) 'action': action,
      if (adminIdentifier != null && adminIdentifier.isNotEmpty)
        'admin_identifier': adminIdentifier,
      if (subjectType != null && subjectType.isNotEmpty)
        'subject_type': subjectType,
      if (subjectId != null && subjectId.isNotEmpty) 'subject_id': subjectId,
      if (from != null) 'created_after': from.toIso8601String(),
      if (to != null) 'created_before': to.toIso8601String(),
    };

    try {
      final response = await _client.requestAdmin<Map<String, dynamic>>(
        '/admin/audit',
        queryParameters: params,
      );
      final body = response.data ?? <String, dynamic>{};
      return Pagination.fromJson(body, (item) => AuditEvent.fromJson(item));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw AdminEndpointMissing('admin/audit');
      }
      rethrow;
    }
  }
}

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuditRepository(client);
});
