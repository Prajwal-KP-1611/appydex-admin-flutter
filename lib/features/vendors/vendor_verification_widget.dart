import 'package:flutter/material.dart';

import '../../models/vendor.dart';

class VendorVerificationResult {
  VendorVerificationResult({required this.approved, this.notes});

  final bool approved;
  final String? notes;
}

Future<VendorVerificationResult?> showVendorVerificationDialog(
  BuildContext context, {
  required Vendor vendor,
}) {
  final notesController = TextEditingController();
  return showDialog<VendorVerificationResult>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Verify ${vendor.companyName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Review KYC and supporting documents before approving.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(
                context,
                VendorVerificationResult(
                  approved: false,
                  notes: notesController.text,
                ),
              );
            },
            child: const Text('Request info'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                VendorVerificationResult(
                  approved: true,
                  notes: notesController.text,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      );
    },
  ).whenComplete(notesController.dispose);
}
