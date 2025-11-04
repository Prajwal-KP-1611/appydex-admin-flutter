import 'package:flutter/material.dart';

class DocumentViewDialog extends StatefulWidget {
  const DocumentViewDialog({
    super.key,
    required this.documentUrl,
    required this.documentName,
    required this.onVerify,
  });

  final String documentUrl;
  final String documentName;
  final Future<void> Function(String reason) onVerify;

  @override
  State<DocumentViewDialog> createState() => _DocumentViewDialogState();
}

class _DocumentViewDialogState extends State<DocumentViewDialog> {
  final _reasonController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a verification reason')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await widget.onVerify(_reasonController.text.trim());
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Verification failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.documentName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // TODO: Implement download functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Download link: Will open in browser'),
                      ),
                    );
                  },
                  tooltip: 'Download',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 64),
                      const SizedBox(height: 16),
                      Text(widget.documentUrl),
                      const SizedBox(height: 8),
                      const Text(
                        'Document preview not available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Verification Reason',
                hintText: 'e.g., Document verified successfully',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isVerifying ? null : _handleVerify,
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified),
                  label: const Text('Mark as Verified'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show document view dialog
Future<bool?> showDocumentViewDialog({
  required BuildContext context,
  required String documentUrl,
  required String documentName,
  required Future<void> Function(String reason) onVerify,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => DocumentViewDialog(
      documentUrl: documentUrl,
      documentName: documentName,
      onVerify: onVerify,
    ),
  );
}
