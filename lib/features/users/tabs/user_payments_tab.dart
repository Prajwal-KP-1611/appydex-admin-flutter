import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/users/user_detail_providers.dart';

/// Payments tab showing user's payment history
class UserPaymentsTab extends ConsumerWidget {
  const UserPaymentsTab({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(userPaymentsProvider(userId));

    return Column(
      children: [
        // Payment Summary Cards
        paymentsAsync.whenOrNull(
              data: (paymentsState) {
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
                                const Text('Total Paid'),
                                Text(
                                  '₹${paymentsState.summary.totalPaid.toStringAsFixed(2)}',
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
                                const Text('Success Rate'),
                                Text(
                                  '${(paymentsState.summary.successRate * 100).toStringAsFixed(1)}%',
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

        // Payments List
        Expanded(
          child: paymentsAsync.when(
            data: (paymentsState) {
              if (paymentsState.items.isEmpty) {
                return const Center(child: Text('No payments yet'));
              }
              return ListView.builder(
                itemCount: paymentsState.items.length,
                itemBuilder: (context, index) {
                  final payment = paymentsState.items[index];
                  return ListTile(
                    title: Text('Payment #${payment.id}'),
                    subtitle: Text(
                      'Gateway: ${payment.paymentGateway ?? "N/A"}\nMethod: ${payment.paymentMethod}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          payment.amountFormatted,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          payment.status,
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
        paymentsAsync.whenOrNull(
              data: (paymentsState) {
                if (paymentsState.totalPages > 1) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Page ${paymentsState.page}/${paymentsState.totalPages}',
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
