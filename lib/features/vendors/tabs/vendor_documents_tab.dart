import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/vendor_detail_providers.dart';

class VendorDocumentsTab extends ConsumerWidget {
  const VendorDocumentsTab({required this.vendorId, super.key});

  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(vendorDocumentsProvider(vendorId));

    return documentsAsync.when(
      data: (documents) {
        if (documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No documents uploaded',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Documents uploaded by the vendor will appear here',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(documents),
              const SizedBox(height: 24),
              _buildDocumentsGrid(context, ref, documents),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load documents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List documents) {
    final verified = documents.where((d) => d.status == 'verified').length;
    final pending = documents.where((d) => d.status == 'pending').length;
    final rejected = documents.where((d) => d.status == 'rejected').length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Documents',
            '${documents.length}',
            Icons.description,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Verified',
            '$verified',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Pending Review',
            '$pending',
            Icons.pending,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Rejected',
            '$rejected',
            Icons.cancel,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsGrid(
    BuildContext context,
    WidgetRef ref,
    List documents,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildDocumentCard(context, ref, doc);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, WidgetRef ref, doc) {
    Color statusColor;
    IconData statusIcon;

    switch (doc.status.toLowerCase()) {
      case 'verified':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Preview/Icon
          Container(
            height: 120,
            color: Colors.grey[100],
            child: Center(
              child: Icon(
                _getDocumentIcon(doc.docType),
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Type
                Text(
                  _formatDocType(doc.docType),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // File Name
                if (doc.fileName != null)
                  Text(
                    doc.fileName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                // Status Chip
                Chip(
                  avatar: Icon(statusIcon, size: 14, color: statusColor),
                  label: Text(
                    doc.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.1),
                  side: BorderSide(color: statusColor.withOpacity(0.3)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                const SizedBox(height: 8),

                // Upload Date
                Text(
                  'Uploaded: ${DateFormat('MMM d, y').format(doc.uploadedAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),

                if (doc.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _verifyDocument(context, ref, doc.id, true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _verifyDocument(context, ref, doc.id, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // View Document Button
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Open document viewer
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'View document: ${doc.fileName ?? doc.docType}',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verifyDocument(
    BuildContext context,
    WidgetRef ref,
    int docId,
    bool approve,
  ) async {
    final action = approve ? 'approve' : 'reject';
    String? notes;

    if (!approve) {
      // Show dialog to get rejection reason
      notes = await showDialog<String>(
        context: context,
        builder: (context) {
          String reason = '';
          return AlertDialog(
            title: const Text('Reject Document'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => reason = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, reason),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          );
        },
      );

      if (notes == null || notes.isEmpty) return; // User cancelled
    }

    try {
      await ref
          .read(vendorDocumentVerificationProvider)
          .verifyDocument(
            vendorId: vendorId,
            documentId: docId.toString(),
            approve: approve,
            notes: notes,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document ${approve ? 'approved' : 'rejected'} successfully',
            ),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );

        // Refresh the documents list
        ref.invalidate(vendorDocumentsProvider(vendorId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getDocumentIcon(String docType) {
    switch (docType.toLowerCase()) {
      case 'pan':
      case 'gst':
      case 'tax':
        return Icons.account_balance_wallet;
      case 'aadhar':
      case 'identity':
      case 'id':
        return Icons.badge;
      case 'bank':
      case 'account':
        return Icons.account_balance;
      case 'license':
      case 'permit':
        return Icons.card_membership;
      case 'certificate':
        return Icons.workspace_premium;
      case 'agreement':
      case 'contract':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDocType(String docType) {
    return docType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
