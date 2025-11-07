import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/analytics_repo.dart';

class AnalyticsDashboardState {
  const AnalyticsDashboardState({
    required this.topSearches,
    required this.ctrSeries,
    required this.start,
    required this.end,
    required this.granularity,
    this.isLoading = false,
    this.error,
  });

  final List<TopSearchItem> topSearches;
  final List<CtrPoint> ctrSeries;
  final DateTime start;
  final DateTime end;
  final String granularity; // day|week
  final bool isLoading;
  final Object? error;

  AnalyticsDashboardState copyWith({
    List<TopSearchItem>? topSearches,
    List<CtrPoint>? ctrSeries,
    DateTime? start,
    DateTime? end,
    String? granularity,
    bool? isLoading,
    Object? error = const _NoUpdate(),
  }) => AnalyticsDashboardState(
    topSearches: topSearches ?? this.topSearches,
    ctrSeries: ctrSeries ?? this.ctrSeries,
    start: start ?? this.start,
    end: end ?? this.end,
    granularity: granularity ?? this.granularity,
    isLoading: isLoading ?? this.isLoading,
    error: error is _NoUpdate ? this.error : error,
  );
}

class _NoUpdate { const _NoUpdate(); }

class AnalyticsDashboardNotifier extends StateNotifier<AnalyticsDashboardState> {
  AnalyticsDashboardNotifier(this._repo)
    : super(AnalyticsDashboardState(
        topSearches: const [],
        ctrSeries: const [],
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
        granularity: 'day',
      )) {
    load();
  }

  final AnalyticsRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: const _NoUpdate());
    try {
      final top = await _repo.fetchTopSearches(start: state.start, end: state.end);
      final ctr = await _repo.fetchCtrSeries(start: state.start, end: state.end, granularity: state.granularity);
      state = state.copyWith(
        topSearches: top,
        ctrSeries: ctr,
        isLoading: false,
        error: const _NoUpdate(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void setRange(Duration duration) {
    final end = DateTime.now();
    final start = end.subtract(duration);
    state = state.copyWith(start: start, end: end);
    load();
  }

  void setGranularity(String value) {
    state = state.copyWith(granularity: value);
    load();
  }
}

final analyticsDashboardProvider = StateNotifierProvider<AnalyticsDashboardNotifier, AnalyticsDashboardState>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return AnalyticsDashboardNotifier(repo);
});
