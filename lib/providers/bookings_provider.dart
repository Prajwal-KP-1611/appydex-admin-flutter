/// Bookings providers for state management
/// Uses Riverpod for dependency injection and state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/paginated_response.dart';
import '../core/permissions.dart';
import '../models/booking.dart';
import '../repositories/bookings_repository.dart';

// ============================================================================
// Repository Provider
// ============================================================================

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingsRepository(apiClient);
});

// ============================================================================
// List Bookings Provider
// ============================================================================

/// Provider for listing bookings with filters
///
/// Usage:
/// ```dart
/// final bookingsAsync = ref.watch(bookingsListProvider(filters));
/// bookingsAsync.when(
///   data: (response) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final bookingsListProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<BookingListItem>, BookingsFilters?>((
      ref,
      filters,
    ) async {
      final repository = ref.watch(bookingsRepositoryProvider);
      return repository.listBookings(filters);
    });

// ============================================================================
// Booking Details Provider
// ============================================================================

/// Provider for fetching booking details by ID
///
/// Usage:
/// ```dart
/// final bookingAsync = ref.watch(bookingDetailsProvider(123));
/// bookingAsync.when(
///   data: (booking) => BookingDetailsView(booking),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final bookingDetailsProvider = FutureProvider.autoDispose
    .family<BookingDetails, int>((ref, bookingId) async {
      final repository = ref.watch(bookingsRepositoryProvider);
      return repository.getBookingDetails(bookingId);
    });

// ============================================================================
// Bookings Filters State Provider
// ============================================================================

/// State provider for managing booking filters
///
/// Usage:
/// ```dart
/// // Read filters
/// final filters = ref.watch(bookingsFiltersProvider);
///
/// // Update filters
/// ref.read(bookingsFiltersProvider.notifier).state = BookingsFilters(
///   status: BookingStatus.pending,
///   page: 1,
/// );
///
/// // Update specific filter
/// ref.read(bookingsFiltersProvider.notifier).update((state) =>
///   state.copyWith(search: searchTerm),
/// );
/// ```
final bookingsFiltersProvider = StateProvider.autoDispose<BookingsFilters>((
  ref,
) {
  return const BookingsFilters();
});

// ============================================================================
// Update Booking Provider
// ============================================================================

/// Provider for updating booking status or adding notes
///
/// This is a stateful provider that tracks loading state and errors
final bookingUpdateProvider =
    StateNotifierProvider.autoDispose<BookingUpdateNotifier, AsyncValue<void>>(
      (ref) => BookingUpdateNotifier(ref),
    );

class BookingUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BookingUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Update a booking
  ///
  /// Example:
  /// ```dart
  /// await ref.read(bookingUpdateProvider.notifier).updateBooking(
  ///   123,
  ///   BookingUpdateRequest(status: BookingStatus.completed),
  /// );
  /// ```
  Future<void> updateBooking(
    int bookingId,
    BookingUpdateRequest request, {
    String? idempotencyKey,
  }) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(bookingsRepositoryProvider);
      await repository.updateBooking(
        bookingId,
        request,
        idempotencyKey: idempotencyKey,
      );

      state = const AsyncValue.data(null);

      // Invalidate related providers to refresh data
      _ref.invalidate(bookingsListProvider);
      _ref.invalidate(bookingDetailsProvider(bookingId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Complete a booking
  Future<void> completeBooking(int bookingId) {
    return updateBooking(
      bookingId,
      const BookingUpdateRequest(status: BookingStatus.completed),
    );
  }

  /// Cancel a booking
  Future<void> cancelBooking(
    int bookingId,
    String cancellationReason, {
    bool notifyUser = true,
    bool notifyVendor = true,
  }) {
    return updateBooking(
      bookingId,
      BookingUpdateRequest(
        status: BookingStatus.canceled,
        cancellationReason: cancellationReason,
        notifyUser: notifyUser,
        notifyVendor: notifyVendor,
      ),
    );
  }

  /// Add admin notes to booking
  Future<void> addAdminNotes(int bookingId, String notes) {
    return updateBooking(
      bookingId,
      BookingUpdateRequest(
        adminNotes: notes,
        notifyUser: false,
        notifyVendor: false,
      ),
    );
  }
}

// ============================================================================
// Bookings Search Provider
// ============================================================================

/// Provider for search functionality with debouncing
///
/// Usage:
/// ```dart
/// // Update search term (debounced)
/// ref.read(bookingsSearchProvider.notifier).updateSearchTerm('BK-2025');
///
/// // Get current search term
/// final searchTerm = ref.watch(bookingsSearchProvider);
/// ```
final bookingsSearchProvider =
    StateNotifierProvider.autoDispose<BookingsSearchNotifier, String>(
      (ref) => BookingsSearchNotifier(ref),
    );

class BookingsSearchNotifier extends StateNotifier<String> {
  final Ref _ref;

  BookingsSearchNotifier(this._ref) : super('');

  /// Update search term and automatically update filters
  void updateSearchTerm(String term) {
    state = term;

    // Update filters with new search term
    _ref.read(bookingsFiltersProvider.notifier).update((filters) {
      return filters.copyWith(search: term.isEmpty ? null : term, page: 1);
    });
  }

  /// Clear search
  void clear() {
    updateSearchTerm('');
  }
}

// ============================================================================
// Bookings Statistics Provider (Optional)
// ============================================================================

/// Provider for booking statistics/metrics
///
/// Usage:
/// ```dart
/// final statsAsync = ref.watch(bookingsStatsProvider);
/// statsAsync.when(
///   data: (stats) => StatsWidget(stats),
///   loading: () => Shimmer(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final bookingsStatsProvider = FutureProvider.autoDispose<BookingsStats>((
  ref,
) async {
  final repository = ref.watch(bookingsRepositoryProvider);

  // Fetch bookings for each status to calculate stats
  // This is a simple implementation - you may want to add a dedicated stats endpoint
  final allBookings = await repository.listBookings(
    const BookingsFilters(pageSize: 100),
  );

  int pending = 0;
  int scheduled = 0;
  int paid = 0;
  int completed = 0;
  int canceled = 0;

  for (final booking in allBookings.data) {
    switch (booking.status) {
      case BookingStatus.pending:
        pending++;
        break;
      case BookingStatus.scheduled:
        scheduled++;
        break;
      case BookingStatus.paid:
        paid++;
        break;
      case BookingStatus.completed:
        completed++;
        break;
      case BookingStatus.canceled:
        canceled++;
        break;
    }
  }

  return BookingsStats(
    total: allBookings.meta.totalItems,
    pending: pending,
    scheduled: scheduled,
    paid: paid,
    completed: completed,
    canceled: canceled,
  );
});

// ============================================================================
// Permission-based providers for Bookings
// =========================================================================

/// Can view bookings list or details
final canViewBookingsProvider = Provider<bool>((ref) {
  final perms = ref.watch(permissionsProvider);
  return perms.contains(Permissions.bookingsList) ||
      perms.contains(Permissions.bookingsView);
});

/// Can perform update actions (complete/cancel/add notes)
final canUpdateBookingsProvider = Provider<bool>((ref) {
  final perms = ref.watch(permissionsProvider);
  return perms.contains(Permissions.bookingsUpdate);
});

/// Bookings statistics model
class BookingsStats {
  final int total;
  final int pending;
  final int scheduled;
  final int paid;
  final int completed;
  final int canceled;

  BookingsStats({
    required this.total,
    required this.pending,
    required this.scheduled,
    required this.paid,
    required this.completed,
    required this.canceled,
  });

  /// Calculate completion rate
  double get completionRate {
    if (total == 0) return 0;
    return (completed / total) * 100;
  }

  /// Calculate cancellation rate
  double get cancellationRate {
    if (total == 0) return 0;
    return (canceled / total) * 100;
  }
}
