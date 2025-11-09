import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users/user_detail_providers.dart';

/// Bookings tab showing user's booking history
class UserBookingsTab extends ConsumerWidget {
  const UserBookingsTab({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider(userId));

    return Column(
      children: [
        // Filters Bar - Coming Soon
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Booking Filters - Coming Soon'),
        ),

        // Bookings List
        Expanded(
          child: bookingsAsync.when(
            data: (pagination) {
              if (pagination.items.isEmpty) {
                return const Center(child: Text('No bookings yet'));
              }
              return ListView.builder(
                itemCount: pagination.items.length,
                itemBuilder: (context, index) {
                  final booking = pagination.items[index];
                  return ListTile(
                    title: Text(booking.serviceName),
                    subtitle: Text(
                      'Ref: ${booking.bookingReference}\nVendor: ${booking.vendorName}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${(booking.amount / 100).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          booking.status,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),

        // Pagination - Coming Soon
        bookingsAsync.whenOrNull(
              data: (pagination) {
                if (pagination.totalPages > 1) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Page ${pagination.page}/${pagination.totalPages}',
                    ),
                  );
                }
                return null;
              },
            ) ??
            const SizedBox.shrink(),
      ],
    );
  }
}
