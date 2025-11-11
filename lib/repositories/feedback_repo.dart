import '../core/api_client.dart';
import '../models/feedback_models.dart';

class FeedbackRepository {
  FeedbackRepository(this._client);

  final ApiClient _client;

  /// List all feedback (admin view with filters)
  /// GET /admin/feedback/
  Future<FeedbackListResponse> listFeedback({
    String? category,
    String? status,
    String? priority,
    bool? hasResponse,
    String? submitterType,
    int page = 1,
    int pageSize = 50,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'page_size': pageSize};

    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;
    if (hasResponse != null) queryParams['has_response'] = hasResponse;
    if (submitterType != null) queryParams['submitter_type'] = submitterType;

    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/feedback/',
      method: 'GET',
      queryParameters: queryParams,
    );

    return FeedbackListResponse.fromJson(response.data!);
  }

  /// Get feedback details with comments
  /// GET /admin/feedback/{feedback_id}
  Future<FeedbackDetails> getFeedbackDetails(int feedbackId) async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/feedback/$feedbackId',
      method: 'GET',
    );

    return FeedbackDetails.fromJson(response.data!);
  }

  /// Update feedback status
  /// PATCH /admin/feedback/{feedback_id}/status
  Future<void> updateStatus({
    required int feedbackId,
    required String status,
    String? internalNote,
  }) async {
    final data = <String, dynamic>{'status': status};

    if (internalNote != null) {
      data['internal_note'] = internalNote;
    }

    await _client.patchIdempotent(
      '/admin/feedback/$feedbackId/status',
      data: data,
    );
  }

  /// Add admin response to feedback
  /// POST /admin/feedback/{feedback_id}/respond
  Future<void> addResponse({
    required int feedbackId,
    required String response,
    String? autoSetStatus,
  }) async {
    final data = <String, dynamic>{'response': response};

    if (autoSetStatus != null) {
      data['auto_set_status'] = autoSetStatus;
    }

    await _client.postIdempotent(
      '/admin/feedback/$feedbackId/respond',
      data: data,
    );
  }

  /// Set feedback priority
  /// PATCH /admin/feedback/{feedback_id}/priority
  Future<void> setPriority({
    required int feedbackId,
    required String priority,
  }) async {
    await _client.patchIdempotent(
      '/admin/feedback/$feedbackId/priority',
      data: {'priority': priority},
    );
  }

  /// Toggle feedback visibility (public/private)
  /// PATCH /admin/feedback/{feedback_id}/visibility
  Future<void> toggleVisibility({
    required int feedbackId,
    required bool isPublic,
  }) async {
    await _client.patchIdempotent(
      '/admin/feedback/$feedbackId/visibility',
      data: {'is_public': isPublic},
    );
  }

  /// Get admin dashboard statistics
  /// GET /admin/feedback/stats
  Future<FeedbackStats> getStats() async {
    final response = await _client.requestAdmin<Map<String, dynamic>>(
      '/admin/feedback/stats',
      method: 'GET',
    );

    return FeedbackStats.fromJson(response.data!);
  }
}
