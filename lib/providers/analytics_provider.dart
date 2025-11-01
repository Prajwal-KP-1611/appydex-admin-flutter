import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics_client.dart';
import '../core/api_client.dart';

final analyticsClientProvider = Provider<AnalyticsClient>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnalyticsClient(apiClient: client);
});

final dashboardMetricsProvider = FutureProvider<Map<String, num>>((ref) async {
  final analytics = ref.watch(analyticsClientProvider);
  return analytics.loadCoreMetrics();
});
