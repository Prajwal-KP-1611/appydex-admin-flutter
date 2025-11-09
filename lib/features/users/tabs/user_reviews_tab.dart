import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users/user_detail_providers.dart';

/// Reviews tab showing user's reviews and ratings
class UserReviewsTab extends ConsumerWidget {
  const UserReviewsTab({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(userReviewsProvider(userId));

    return Column(
      children: [
        // Filters Bar - Coming Soon
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text('Review Filters - Coming Soon'),
        ),

        // Reviews List
        Expanded(
          child: reviewsAsync.when(
            data: (pagination) {
              if (pagination.items.isEmpty) {
                return const Center(child: Text('No reviews yet'));
              }
              return ListView.builder(
                itemCount: pagination.items.length,
                itemBuilder: (context, index) {
                  final review = pagination.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(review.ratingStars),
                              const SizedBox(width: 8),
                              Text(
                                review.sentiment,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (review.isVerified)
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.serviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (review.title != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              review.title!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (review.comment != null) ...[
                            const SizedBox(height: 8),
                            Text(review.comment!),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Posted on ${review.createdAt}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),

        // Pagination - Coming Soon
        reviewsAsync.whenOrNull(
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
