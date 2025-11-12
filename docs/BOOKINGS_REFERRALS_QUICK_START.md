# Quick Start: Using Bookings and Referrals Providers

## Bookings

### List Bookings
```dart
class BookingsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(bookingsFiltersProvider);
    final bookingsAsync = ref.watch(bookingsListProvider(filters));
    
    return bookingsAsync.when(
      data: (response) => ListView.builder(
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final booking = response.data[index];
          return ListTile(
            title: Text(booking.bookingNumber),
            subtitle: Text(booking.user.name),
            trailing: StatusBadge(booking.status),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Filter Bookings
```dart
// Change filter
ref.read(bookingsFiltersProvider.notifier).state = BookingsFilters(
  status: BookingStatus.pending,
  fromDate: DateTime(2025, 1, 1),
  page: 1,
);

// Or update specific field
ref.read(bookingsFiltersProvider.notifier).update((state) =>
  state.copyWith(status: BookingStatus.completed),
);
```

### Search Bookings
```dart
// Search automatically updates filters with debouncing
ref.read(bookingsSearchProvider.notifier).updateSearchTerm('BK-2025');

// Clear search
ref.read(bookingsSearchProvider.notifier).clear();
```

### Update Booking
```dart
// Complete a booking
await ref.read(bookingUpdateProvider.notifier).completeBooking(123);

// Cancel with reason
await ref.read(bookingUpdateProvider.notifier).cancelBooking(
  123,
  'Customer requested cancellation',
  notifyUser: true,
  notifyVendor: true,
);

// Add admin notes
await ref.read(bookingUpdateProvider.notifier).addAdminNotes(
  123,
  'Contacted vendor - issue resolved',
);

// Custom update
await ref.read(bookingUpdateProvider.notifier).updateBooking(
  123,
  BookingUpdateRequest(
    status: BookingStatus.completed,
    adminNotes: 'Service completed successfully',
  ),
);
```

### View Booking Details
```dart
final bookingAsync = ref.watch(bookingDetailsProvider(bookingId));

return bookingAsync.when(
  data: (booking) => Column(
    children: [
      Text('Booking: ${booking.bookingNumber}'),
      Text('Status: ${booking.status.displayName}'),
      Text('User: ${booking.user.name}'),
      Text('Vendor: ${booking.vendor.displayName}'),
      Text('Scheduled: ${booking.scheduledAt}'),
      if (booking.idempotencyKey != null)
        Text('Idempotency: ${booking.idempotencyKey}'),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Bookings Statistics
```dart
final statsAsync = ref.watch(bookingsStatsProvider);

return statsAsync.when(
  data: (stats) => Row(
    children: [
      StatCard('Total', stats.total),
      StatCard('Pending', stats.pending),
      StatCard('Completed', stats.completed),
      StatCard('Completion Rate', '${stats.completionRate.toStringAsFixed(1)}%'),
    ],
  ),
  loading: () => Shimmer(),
  error: (error, stack) => ErrorWidget(error),
);
```

## Referrals

### List Referrals
```dart
class ReferralsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(referralsFiltersProvider);
    final referralsAsync = ref.watch(referralsListProvider(filters));
    
    return referralsAsync.when(
      data: (response) => ListView.builder(
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final referral = response.data[index];
          return ListTile(
            title: Text('Referral #${referral.id}'),
            subtitle: Text(referral.referrerVendor?.name ?? 'Unknown'),
            trailing: Column(
              children: [
                StatusBadge(referral.status),
                if (referral.tier != null) TierBadge(referral.tier!),
              ],
            ),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Filter Referrals
```dart
// By status
ref.read(referralStatusFilterProvider.notifier).state = ReferralStatus.completed;

// By tier
ref.read(referralTierFilterProvider.notifier).state = 'gold';

// By date range
ref.read(referralDateRangeProvider.notifier).state = (
  start: DateTime(2025, 1, 1),
  end: DateTime(2025, 1, 31),
);

// Or update filters directly
ref.read(referralsFiltersProvider.notifier).state = ReferralsFilters(
  status: ReferralStatus.pending,
  tier: 'gold',
  startDate: DateTime(2025, 1, 1),
  page: 1,
);
```

### Vendor Referral Stats
```dart
final statsAsync = ref.watch(vendorReferralsProvider(vendorId));

return statsAsync.when(
  data: (stats) => Column(
    children: [
      Text('Vendor: ${stats.vendorName}'),
      Text('Total Referrals: ${stats.totalReferrals}'),
      Text('Pending: ${stats.pendingReferrals}'),
      Text('Completed: ${stats.completedReferrals}'),
      Text('Total Rewards: \$${stats.totalRewardsEarned}'),
      Text('Recent Referrals: ${stats.recentReferrals.length}'),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Top Referrers Leaderboard
```dart
final topReferrersAsync = ref.watch(topReferrersProvider(10));

return topReferrersAsync.when(
  data: (referrers) => ListView.builder(
    itemCount: referrers.length,
    itemBuilder: (context, index) {
      final referrer = referrers[index];
      return ListTile(
        leading: Text('#${index + 1}'),
        title: Text(referrer.vendorName),
        subtitle: Text(referrer.vendorEmail),
        trailing: Column(
          children: [
            Text('${referrer.referralCount} referrals'),
            Text('\$${referrer.totalRewards.toStringAsFixed(2)}'),
          ],
        ),
      );
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Referrals Statistics
```dart
final statsAsync = ref.watch(referralsStatsProvider);

return statsAsync.when(
  data: (stats) => GridView(
    children: [
      StatCard('Total', stats.total),
      StatCard('Pending', stats.pending),
      StatCard('Completed', stats.completed),
      StatCard('Total Rewards', '\$${stats.totalRewards.toStringAsFixed(2)}'),
      StatCard('Avg Reward', '\$${stats.averageReward.toStringAsFixed(2)}'),
      StatCard('Active Tiers', stats.activeTiers),
      StatCard('Completion Rate', '${stats.completionRate.toStringAsFixed(1)}%'),
    ],
  ),
  loading: () => Shimmer(),
  error: (error, stack) => ErrorWidget(error),
);
```

## Pagination

### Navigate Pages
```dart
// Next page
if (response.hasNextPage) {
  ref.read(bookingsFiltersProvider.notifier).update((state) =>
    state.copyWith(page: response.nextPage),
  );
}

// Previous page
if (response.hasPrevPage) {
  ref.read(bookingsFiltersProvider.notifier).update((state) =>
    state.copyWith(page: response.prevPage),
  );
}

// Specific page
ref.read(bookingsFiltersProvider.notifier).update((state) =>
  state.copyWith(page: 3),
);
```

### Pagination Widget
```dart
class PaginationControls extends ConsumerWidget {
  final PaginatedResponse response;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: response.hasPrevPage
              ? () => ref.read(bookingsFiltersProvider.notifier).update(
                    (state) => state.copyWith(page: response.prevPage),
                  )
              : null,
        ),
        Text('Page ${response.meta.page} of ${response.meta.totalPages}'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: response.hasNextPage
              ? () => ref.read(bookingsFiltersProvider.notifier).update(
                    (state) => state.copyWith(page: response.nextPage),
                  )
              : null,
        ),
      ],
    );
  }
}
```

## Error Handling

### Handling Specific Exceptions
```dart
try {
  await ref.read(bookingUpdateProvider.notifier).updateBooking(
    123,
    BookingUpdateRequest(status: BookingStatus.completed),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Booking updated successfully')),
  );
} on InvalidStatusTransitionException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Cannot change from ${e.currentStatus} to ${e.requestedStatus}'),
      backgroundColor: Colors.red,
    ),
  );
} on BookingNotFoundException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Booking ${e.bookingId} not found'),
      backgroundColor: Colors.red,
    ),
  );
} on AdminEndpointMissing catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Permission denied: ${e.message}'),
      backgroundColor: Colors.orange,
    ),
  );
}
```

### AsyncValue Error Handling
```dart
final bookingsAsync = ref.watch(bookingsListProvider(filters));

return bookingsAsync.when(
  data: (response) => BookingsList(response),
  loading: () => Center(child: CircularProgressIndicator()),
  error: (error, stack) {
    if (error is DioException) {
      final appError = error.error;
      if (appError is AppHttpException) {
        return ErrorView(
          message: appError.message,
          statusCode: appError.statusCode,
          traceId: appError.traceId,
          onRetry: () => ref.invalidate(bookingsListProvider),
        );
      }
    }
    return ErrorView(
      message: error.toString(),
      onRetry: () => ref.invalidate(bookingsListProvider),
    );
  },
);
```

## Refresh Data

### Manual Refresh
```dart
// Refresh bookings list
ref.invalidate(bookingsListProvider);

// Refresh specific booking details
ref.invalidate(bookingDetailsProvider(bookingId));

// Refresh referrals
ref.invalidate(referralsListProvider);
```

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(bookingsListProvider);
    // Wait for the provider to reload
    await ref.read(bookingsListProvider(filters).future);
  },
  child: BookingsList(),
)
```

## Status Colors

### Booking Status Colors
```dart
Color getBookingColor(BookingStatus status) {
  return Color(int.parse(status.colorHex.replaceFirst('#', '0xFF')));
}

// In widget:
Container(
  color: getBookingColor(booking.status),
  child: Text(booking.status.displayName),
)
```

### Referral Status Colors
```dart
Color getReferralColor(ReferralStatus status) {
  return Color(int.parse(status.colorHex.replaceFirst('#', '0xFF')));
}
```

## Tips

1. **Always use filters provider** for list views - don't pass filters directly
2. **Invalidate providers** after mutations to refresh data
3. **Check AsyncValue state** before accessing data
4. **Handle null vendor** in referrals (use `referral.referrerVendor?.name`)
5. **Use idempotency keys** for retryable operations
6. **Debounce search inputs** - already handled by searchProvider
7. **Show loading states** - improves UX during API calls
8. **Display error messages** - users need feedback on failures
