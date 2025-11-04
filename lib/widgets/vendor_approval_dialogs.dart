import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';

/// Dialog for approving a vendor
class ApproveVendorDialog extends StatefulWidget {
  const ApproveVendorDialog({super.key, required this.vendorName});

  final String vendorName;

  @override
  State<ApproveVendorDialog> createState() => _ApproveVendorDialogState();
}

class _ApproveVendorDialogState extends State<ApproveVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Vendor'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to approve "${widget.vendorName}"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Mark the vendor as verified'),
              const Text('• Allow the vendor to receive bookings'),
              const Text('• Send approval notification to vendor'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any internal notes...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    Validators.maxLength(value, 500, fieldName: 'Notes'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _notesController.text.trim());
            }
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

/// Dialog for rejecting a vendor
class RejectVendorDialog extends StatefulWidget {
  const RejectVendorDialog({super.key, required this.vendorName});

  final String vendorName;

  @override
  State<RejectVendorDialog> createState() => _RejectVendorDialogState();
}

class _RejectVendorDialogState extends State<RejectVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Vendor'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to reject "${widget.vendorName}"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Mark the vendor as not verified'),
              const Text('• Prevent the vendor from receiving bookings'),
              const Text('• Send rejection notification to vendor'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason *',
                  hintText: 'Explain why this vendor is being rejected...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: Validators.combine([
                  (value) => Validators.required(value, fieldName: 'Reason'),
                  (value) =>
                      Validators.minLength(value, 10, fieldName: 'Reason'),
                  (value) =>
                      Validators.maxLength(value, 500, fieldName: 'Reason'),
                ]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _reasonController.text.trim());
            }
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
