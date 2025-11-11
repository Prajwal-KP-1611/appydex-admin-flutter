import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages automatic token refresh to prevent expiration.
///
/// Uses a fixed interval approach (refreshes every N minutes) to ensure
/// tokens are always fresh. This is a simple, dependency-free solution
/// that works regardless of token expiry time.
///
/// For a more optimal solution, see TOKEN_REFRESH_ENHANCEMENT.md which
/// proposes either JWT parsing or backend-provided expiry information.
class TokenManager {
  TokenManager({this.refreshInterval = const Duration(minutes: 10)});

  /// How often to refresh tokens proactively.
  /// Default: 10 minutes (safe for 15-minute token expiry, provides 1.5x buffer)
  final Duration refreshInterval;

  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;

  /// Starts automatic token refresh in the background.
  ///
  /// [onRefresh] will be called periodically to refresh tokens.
  /// Typically this should call ApiClient.refreshTokens().
  void startAutoRefresh(Future<void> Function() onRefresh) {
    stopAutoRefresh();

    if (kDebugMode) {
      debugPrint(
        '[TokenManager] Starting auto-refresh every ${refreshInterval.inMinutes} minutes',
      );
    }

    // Refresh immediately if needed, then start periodic refresh
    _scheduleNextRefresh(onRefresh);
  }

  void _scheduleNextRefresh(Future<void> Function() onRefresh) {
    final now = DateTime.now();

    // Calculate when to refresh
    Duration delay = refreshInterval;
    if (_lastRefreshTime != null) {
      final timeSinceLastRefresh = now.difference(_lastRefreshTime!);
      final timeUntilNextRefresh = refreshInterval - timeSinceLastRefresh;

      if (timeUntilNextRefresh.isNegative) {
        // Overdue, refresh immediately
        delay = Duration.zero;
      } else {
        delay = timeUntilNextRefresh;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[TokenManager] Next refresh in ${delay.inMinutes} minutes ${delay.inSeconds % 60} seconds',
      );
    }

    _refreshTimer = Timer(delay, () async {
      try {
        if (kDebugMode) {
          debugPrint('[TokenManager] Auto-refreshing tokens...');
        }

        await onRefresh();
        _lastRefreshTime = DateTime.now();

        if (kDebugMode) {
          debugPrint('[TokenManager] Tokens refreshed successfully');
        }

        // Schedule next refresh
        _scheduleNextRefresh(onRefresh);
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('[TokenManager] Auto-refresh failed: $e');
          debugPrint(stack.toString());
        }

        // Retry sooner if refresh failed (1 minute)
        Timer(const Duration(minutes: 1), () {
          _scheduleNextRefresh(onRefresh);
        });
      }
    });
  }

  /// Stops automatic token refresh.
  /// Should be called on logout or when tokens are no longer valid.
  void stopAutoRefresh() {
    if (_refreshTimer != null) {
      if (kDebugMode) {
        debugPrint('[TokenManager] Stopping auto-refresh');
      }

      _refreshTimer?.cancel();
      _refreshTimer = null;
      _lastRefreshTime = null;
    }
  }

  /// Updates the last refresh time (useful after manual refresh).
  void markRefreshed() {
    _lastRefreshTime = DateTime.now();
  }

  /// Returns true if auto-refresh is currently active.
  bool get isActive => _refreshTimer != null && _refreshTimer!.isActive;

  /// Time until next scheduled refresh, or null if not active.
  Duration? get timeUntilNextRefresh {
    if (_lastRefreshTime == null || !isActive) return null;

    final elapsed = DateTime.now().difference(_lastRefreshTime!);
    final remaining = refreshInterval - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Clean up resources.
  void dispose() {
    stopAutoRefresh();
  }
}
