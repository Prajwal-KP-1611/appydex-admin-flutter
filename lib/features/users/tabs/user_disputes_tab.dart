import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users/user_disputes_provider.dart';

/// Disputes tab showing user's disputes
class UserDisputesTab extends ConsumerWidget {
  const UserDisputesTab({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputesAsync = ref.watch(userDisputesProvider(userId));

    return Column(
      children: [
        // Disputes Summary
        disputesAsync.whenOrNull(
              data: (disputesState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Total'),
                                Text(
                                  '${disputesState.summary.totalDisputes}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Open'),
                                Text(
                                  '${disputesState.summary.open}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Win Rate'),
                                Text(
                                  '${(disputesState.summary.userWinRate * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            const SizedBox.shrink(),

        // Disputes List
        Expanded(
          child: disputesAsync.when(
            data: (disputesState) {
              if (disputesState.items.isEmpty) {
                return const Center(child: Text('No disputes filed'));
              }
              return ListView.builder(
                itemCount: disputesState.items.length,
                itemBuilder: (context, index) {
                  final dispute = disputesState.items[index];
                  return ListTile(
                    title: Text(dispute.type.name),
                    subtitle: Text(
                      'Ref: ${dispute.disputeReference}\n${dispute.description}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dispute.amountDisputedFormatted,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dispute.status.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      // TODO: Open dispute detail dialog
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),

        // Pagination - Coming Soon
        disputesAsync.whenOrNull(
              data: (disputesState) {
                if (disputesState.totalPages > 1) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Page ${disputesState.page}/${disputesState.totalPages}',
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
