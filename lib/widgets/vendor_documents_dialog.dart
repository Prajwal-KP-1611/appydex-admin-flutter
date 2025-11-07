import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:appydex_admin/models/vendor.dart';
import '../../repositories/vendor_repo.dart';

/// Dialog to view vendor KYC documents
class VendorDocumentsDialog extends ConsumerWidget {
  const VendorDocumentsDialog({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  final int vendorId;
  final String vendorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(_vendorDocumentsProvider(vendorId));

    return Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            // Header
            AppBar(
              title: Text('Documents - $vendorName'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Document list
            Expanded(
              child: documentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading documents: $error'),
                    ],
                  ),
                ),
                data: (documents) {
                  if (documents.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No documents uploaded',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This vendor has not uploaded any documents yet.',
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(_iconForType(doc.docType)),
                          ),
                          title: Text(
                            doc.displayType,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('File: ${doc.fileName}'),
                              const SizedBox(height: 2),
                              Text(
                                'Uploaded: ${DateFormat('MMM d, y h:mm a').format(doc.uploadedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Status chip
                              Chip(
                                label: Text(
                                  doc.verificationStatus.toUpperCase(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: _getStatusColor(
                                  doc.verificationStatus,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // View button
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                tooltip: 'View document',
                                onPressed: () =>
                                    _openDocument(context, doc.filePath),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.withValues(alpha: 0.2);
      case 'rejected':
        return Colors.red.withValues(alpha: 0.2);
      case 'pending':
      default:
        return Colors.orange.withValues(alpha: 0.2);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'business_license':
        return Icons.business;
      case 'tax_document':
        return Icons.receipt;
      case 'identity_proof':
        return Icons.badge;
      case 'address_proof':
        return Icons.location_on;
      default:
        return Icons.description;
    }
  }

  void _openDocument(BuildContext context, String filePath) {
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document URL not available')),
      );
      return;
    }

    // Show full-screen document viewer
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(filePath: filePath),
    );
  }
}

/// Full-screen document viewer
class DocumentViewerDialog extends StatelessWidget {
  const DocumentViewerDialog({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download',
              onPressed: () => _downloadDocument(context),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Document Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: $filePath',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openInBrowser(filePath),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in Browser'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Full document preview requires integration with a PDF viewer library',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInBrowser(String path) {
    // In a real app, use url_launcher package
    // For now, this is a placeholder
    debugPrint('Opening URL: $path');
  }

  void _downloadDocument(BuildContext context) {
    // In a real app, implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality to be implemented')),
    );
  }
}

/// Provider for vendor documents
final _vendorDocumentsProvider =
    FutureProvider.family<List<VendorDocument>, int>((ref, vendorId) async {
      final repository = ref.watch(vendorRepositoryProvider);
      return repository.getDocuments(vendorId);
    });
