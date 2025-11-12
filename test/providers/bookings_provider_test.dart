/// Unit tests for Bookings and Referrals Stats
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:appydex_admin/providers/bookings_provider.dart';
import 'package:appydex_admin/providers/referrals_provider.dart';

void main() {
  group('BookingsStats', () {
    test('should calculate completion rate correctly', () {
      final stats = BookingsStats(
        total: 100,
        pending: 20,
        scheduled: 15,
        paid: 10,
        completed: 50,
        canceled: 5,
      );

      expect(stats.completionRate, 50.0);
    });

    test('should calculate cancellation rate correctly', () {
      final stats = BookingsStats(
        total: 100,
        pending: 20,
        scheduled: 15,
        paid: 10,
        completed: 50,
        canceled: 5,
      );

      expect(stats.cancellationRate, 5.0);
    });

    test('should return 0 for rates when total is zero', () {
      final stats = BookingsStats(
        total: 0,
        pending: 0,
        scheduled: 0,
        paid: 0,
        completed: 0,
        canceled: 0,
      );

      expect(stats.completionRate, 0.0);
      expect(stats.cancellationRate, 0.0);
    });

    test('should handle non-round percentages', () {
      final stats = BookingsStats(
        total: 3,
        pending: 0,
        scheduled: 0,
        paid: 0,
        completed: 1,
        canceled: 2,
      );

      expect(stats.completionRate, closeTo(33.333, 0.001));
      expect(stats.cancellationRate, closeTo(66.666, 0.001));
    });
  });

  group('ReferralsStats', () {
    test('should calculate completion rate correctly', () {
      final stats = ReferralsStats(
        total: 100,
        pending: 30,
        completed: 65,
        cancelled: 5,
        totalRewards: 1000.0,
        activeTiers: 4,
      );

      expect(stats.completionRate, 65.0);
    });

    test('should calculate average reward correctly', () {
      final stats = ReferralsStats(
        total: 100,
        pending: 30,
        completed: 50,
        cancelled: 20,
        totalRewards: 5000.0,
        activeTiers: 4,
      );

      expect(stats.averageReward, 100.0);
    });

    test('should return 0 for average reward when no completions', () {
      final stats = ReferralsStats(
        total: 100,
        pending: 100,
        completed: 0,
        cancelled: 0,
        totalRewards: 0.0,
        activeTiers: 4,
      );

      expect(stats.averageReward, 0.0);
    });
  });
}
