import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../models/feedback_models.dart';
import '../../repositories/feedback_repo.dart';

// Repository provider
final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedbackRepository(apiClient);
});

// Filter state providers
final feedbackCategoryFilterProvider = StateProvider<String?>((ref) => null);
final feedbackStatusFilterProvider = StateProvider<String?>((ref) => null);
final feedbackPriorityFilterProvider = StateProvider<String?>((ref) => null);
final feedbackSubmitterTypeFilterProvider = StateProvider<String?>(
  (ref) => null,
);
final feedbackHasResponseFilterProvider = StateProvider<bool?>((ref) => null);
final feedbackPageProvider = StateProvider<int>((ref) => 1);

// Feedback list provider with filters
final feedbackListProvider = FutureProvider.autoDispose<FeedbackListResponse>((
  ref,
) async {
  final repo = ref.watch(feedbackRepositoryProvider);
  final category = ref.watch(feedbackCategoryFilterProvider);
  final status = ref.watch(feedbackStatusFilterProvider);
  final priority = ref.watch(feedbackPriorityFilterProvider);
  final submitterType = ref.watch(feedbackSubmitterTypeFilterProvider);
  final hasResponse = ref.watch(feedbackHasResponseFilterProvider);
  final page = ref.watch(feedbackPageProvider);

  return repo.listFeedback(
    category: category,
    status: status,
    priority: priority,
    submitterType: submitterType,
    hasResponse: hasResponse,
    page: page,
  );
});

// Feedback detail provider
final feedbackDetailProvider = FutureProvider.family
    .autoDispose<FeedbackDetails, int>((ref, feedbackId) async {
      final repo = ref.watch(feedbackRepositoryProvider);
      return repo.getFeedbackDetails(feedbackId);
    });

// Feedback stats provider
final feedbackStatsProvider = FutureProvider.autoDispose<FeedbackStats>((
  ref,
) async {
  final repo = ref.watch(feedbackRepositoryProvider);
  return repo.getStats();
});

// Action providers for mutations
class FeedbackActions {
  FeedbackActions(this._ref);
  final Ref _ref;

  Future<void> updateStatus({
    required int feedbackId,
    required String status,
    String? internalNote,
  }) async {
    final repo = _ref.read(feedbackRepositoryProvider);
    await repo.updateStatus(
      feedbackId: feedbackId,
      status: status,
      internalNote: internalNote,
    );
    // Invalidate relevant providers
    _ref.invalidate(feedbackListProvider);
    _ref.invalidate(feedbackDetailProvider(feedbackId));
    _ref.invalidate(feedbackStatsProvider);
  }

  Future<void> addResponse({
    required int feedbackId,
    required String response,
    String? autoSetStatus,
  }) async {
    final repo = _ref.read(feedbackRepositoryProvider);
    await repo.addResponse(
      feedbackId: feedbackId,
      response: response,
      autoSetStatus: autoSetStatus,
    );
    _ref.invalidate(feedbackListProvider);
    _ref.invalidate(feedbackDetailProvider(feedbackId));
    _ref.invalidate(feedbackStatsProvider);
  }

  Future<void> setPriority({
    required int feedbackId,
    required String priority,
  }) async {
    final repo = _ref.read(feedbackRepositoryProvider);
    await repo.setPriority(feedbackId: feedbackId, priority: priority);
    _ref.invalidate(feedbackListProvider);
    _ref.invalidate(feedbackDetailProvider(feedbackId));
  }

  Future<void> toggleVisibility({
    required int feedbackId,
    required bool isPublic,
  }) async {
    final repo = _ref.read(feedbackRepositoryProvider);
    await repo.toggleVisibility(feedbackId: feedbackId, isPublic: isPublic);
    _ref.invalidate(feedbackListProvider);
    _ref.invalidate(feedbackDetailProvider(feedbackId));
  }
}

final feedbackActionsProvider = Provider<FeedbackActions>((ref) {
  return FeedbackActions(ref);
});
