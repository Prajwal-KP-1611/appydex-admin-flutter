import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorApplicationTab extends ConsumerWidget {
  const VendorApplicationTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(vendorApplicationProvider(vendorId));

    return applicationAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Failed to load application: $error'),
          ],
        ),
      ),
      data: (application) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status overview card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_turned_in, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Application Status',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  application.registrationStatus.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      application.registrationStatus,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (application.isVerified)
                            const Chip(
                              avatar: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text('VERIFIED'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            )
                          else if (application.isPending)
                            const Chip(
                              avatar: Icon(
                                Icons.schedule,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text('PENDING'),
                              backgroundColor: Colors.orange,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Progress bar
                      Text(
                        'Registration Progress: ${application.registrationProgress}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: application.registrationProgress / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          application.registrationProgress == 100
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Applied date
              _InfoRow(
                'Applied',
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(application.appliedAt),
                icon: Icons.event,
              ),
              const SizedBox(height: 12),

              // Current step
              _InfoRow(
                'Current Step',
                application.registrationStep,
                icon: Icons.stairs,
              ),
              const SizedBox(height: 24),

              // Incomplete fields section
              if (application.hasIncompleteFields) ...[
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Incomplete Fields',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...application.incompleteFields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    field,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Missing documents section
              if (application.missingDocuments.isNotEmpty) ...[
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Missing Documents',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...application.missingDocuments.map(
                          (doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doc,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Empty state
              if (!application.hasIncompleteFields &&
                  application.missingDocuments.isEmpty &&
                  application.registrationProgress == 100) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green[700],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Application Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'All required fields and documents are submitted',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
        ],
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
