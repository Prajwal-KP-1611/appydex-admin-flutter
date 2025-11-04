import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../models/service_type_request.dart';
import '../../repositories/service_type_request_repo.dart';

/// Dialog for approving service type requests
class ApproveRequestDialog extends ConsumerStatefulWidget {
  const ApproveRequestDialog({super.key, required this.request});

  final ServiceTypeRequest request;

  @override
  ConsumerState<ApproveRequestDialog> createState() =>
      _ApproveRequestDialogState();
}

class _ApproveRequestDialogState extends ConsumerState<ApproveRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Approve Service Type Request'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow('Service Type', widget.request.requestedName),
                      if (widget.request.requestedDescription != null)
                        _InfoRow(
                          'Description',
                          widget.request.requestedDescription!,
                        ),
                      _InfoRow(
                        'Vendor',
                        widget.request.vendorName ??
                            'ID: ${widget.request.vendorId}',
                      ),
                      if (widget.request.justification != null)
                        _InfoRow(
                          'Justification',
                          widget.request.justification!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Approval will create a new service type in the master catalog.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Review Notes (Optional)',
                    hintText: 'Add any notes for the vendor...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _handleApprove,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle),
          label: const Text('Approve'),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Future<void> _handleApprove() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notes = _notesController.text.trim();
      await ref
          .read(serviceTypeRequestsProvider.notifier)
          .approve(
            widget.request.id,
            reviewNotes: notes.isEmpty ? null : notes,
          );

      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(
          context,
          'Request approved! Service type "${widget.request.requestedName}" created.',
        );
      }
    } catch (error) {
      if (mounted) {
        ToastService.showError(context, 'Failed to approve request: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Dialog for rejecting service type requests
class RejectRequestDialog extends ConsumerStatefulWidget {
  const RejectRequestDialog({super.key, required this.request});

  final ServiceTypeRequest request;

  @override
  ConsumerState<RejectRequestDialog> createState() =>
      _RejectRequestDialogState();
}

class _RejectRequestDialogState extends ConsumerState<RejectRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cancel, color: AppTheme.dangerRed, size: 28),
          SizedBox(width: 12),
          Text('Reject Service Type Request'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow('Service Type', widget.request.requestedName),
                      if (widget.request.requestedDescription != null)
                        _InfoRow(
                          'Description',
                          widget.request.requestedDescription!,
                        ),
                      _InfoRow(
                        'Vendor',
                        widget.request.vendorName ??
                            'ID: ${widget.request.vendorId}',
                      ),
                      if (widget.request.justification != null)
                        _InfoRow(
                          'Justification',
                          widget.request.justification!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppTheme.dangerRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Rejection feedback is required (minimum 10 characters).',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason *',
                    hintText: 'Explain why this request is being rejected...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    helperText: 'Minimum 10 characters required',
                  ),
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason for rejection';
                    }
                    if (value.trim().length < 10) {
                      return 'Rejection reason must be at least 10 characters';
                    }
                    if (value.trim().length > 500) {
                      return 'Rejection reason must not exceed 500 characters';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _handleReject,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cancel),
          label: const Text('Reject'),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
        ),
      ],
    );
  }

  Future<void> _handleReject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(serviceTypeRequestsProvider.notifier)
          .reject(widget.request.id, reviewNotes: _notesController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(context, 'Request rejected');
      }
    } catch (error) {
      if (mounted) {
        ToastService.showError(context, 'Failed to reject request: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
