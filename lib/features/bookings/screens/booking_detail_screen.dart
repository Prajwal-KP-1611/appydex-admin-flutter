/// Booking detail screen with admin actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/error_mapper.dart';
import '../../../models/booking.dart';
import '../../../providers/bookings_provider.dart';
import '../../../repositories/bookings_repository.dart';
import '../../../widgets/loading_indicator.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const BookingDetailScreen({required this.bookingId, super.key});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  final _notesController = TextEditingController();
  final _cancellationReasonController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _cancellationReasonController.dispose();
    super.dispose();
  }

  Future<void> _completeBooking() async {
    // Permission gate - hide action if user lacks update permission
    final canUpdate = ref.read(canUpdateBookingsProvider);
    if (!canUpdate) {
      _showErrorDialog(
        'Action not allowed',
        'You do not have permission to update bookings.',
      );
      return;
    }
    final confirmed = await _showConfirmDialog(
      'Complete Booking',
      'Are you sure you want to mark this booking as completed?',
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(bookingUpdateProvider.notifier)
          .completeBooking(widget.bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(bookingDetailsProvider(widget.bookingId));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          ErrorMapper.getErrorTitle(e),
          ErrorMapper.mapErrorToMessage(e),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    final canUpdate = ref.read(canUpdateBookingsProvider);
    if (!canUpdate) {
      _showErrorDialog(
        'Action not allowed',
        'You do not have permission to cancel bookings.',
      );
      return;
    }
    final reason = await _showCancellationDialog();
    if (reason == null || reason.isEmpty) return;

    try {
      await ref
          .read(bookingUpdateProvider.notifier)
          .cancelBooking(
            widget.bookingId,
            reason,
            notifyUser: true,
            notifyVendor: true,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        ref.invalidate(bookingDetailsProvider(widget.bookingId));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          ErrorMapper.getErrorTitle(e),
          ErrorMapper.mapErrorToMessage(e),
        );
      }
    }
  }

  Future<void> _addNotes() async {
    final canUpdate = ref.read(canUpdateBookingsProvider);
    if (!canUpdate) {
      _showErrorDialog(
        'Action not allowed',
        'You do not have permission to add notes.',
      );
      return;
    }
    final notes = await _showNotesDialog();
    if (notes == null || notes.isEmpty) return;

    try {
      await ref
          .read(bookingUpdateProvider.notifier)
          .addAdminNotes(widget.bookingId, notes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes added successfully')),
        );
        ref.invalidate(bookingDetailsProvider(widget.bookingId));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          ErrorMapper.getErrorTitle(e),
          ErrorMapper.mapErrorToMessage(e),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCancellationDialog() {
    _cancellationReasonController.clear();
    String? validationError;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cancel Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for cancellation:'),
              const SizedBox(height: 16),
              TextField(
                controller: _cancellationReasonController,
                decoration: InputDecoration(
                  hintText: 'Cancellation reason (10-200 characters)',
                  border: const OutlineInputBorder(),
                  errorText: validationError,
                  counterText: '',
                ),
                maxLength: 200,
                maxLines: 3,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    validationError = _validateReason(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = _cancellationReasonController.text.trim();
                final error = _validateReason(reason);
                if (error != null) {
                  setState(() {
                    validationError = error;
                  });
                  return;
                }
                Navigator.pop(context, reason);
              },
              child: const Text('Cancel Booking'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateReason(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Reason is required';
    }
    if (trimmed.length < 10) {
      return 'Reason must be at least 10 characters';
    }
    if (trimmed.length > 200) {
      return 'Reason must not exceed 200 characters';
    }
    return null;
  }

  Future<String?> _showNotesDialog() {
    _notesController.clear();
    String? validationError;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Admin Notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Enter your notes here... (5-500 characters)',
                  border: const OutlineInputBorder(),
                  errorText: validationError,
                  counterText: '',
                ),
                maxLength: 500,
                maxLines: 5,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    validationError = _validateNotes(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final notes = _notesController.text.trim();
                final error = _validateNotes(notes);
                if (error != null) {
                  setState(() {
                    validationError = error;
                  });
                  return;
                }
                Navigator.pop(context, notes);
              },
              child: const Text('Save Notes'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateNotes(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Notes are required';
    }
    if (trimmed.length < 5) {
      return 'Notes must be at least 5 characters';
    }
    if (trimmed.length > 500) {
      return 'Notes must not exceed 500 characters';
    }
    return null;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailsProvider(widget.bookingId));
    final canUpdate = ref.watch(canUpdateBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(bookingDetailsProvider(widget.bookingId)),
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) => _buildBookingDetails(booking, canUpdate: canUpdate),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildErrorView(error),
      ),
    );
  }

  Widget _buildBookingDetails(
    BookingDetails booking, {
    required bool canUpdate,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with booking number and status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Number',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.bookingNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(booking.status),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User information
          _buildSectionCard('User Information', Icons.person, [
            _buildInfoRow('Name', booking.user.name),
            _buildInfoRow('Email', booking.user.email),
            if (booking.user.phone != null)
              _buildInfoRow('Phone', booking.user.phone!),
            if (booking.user.totalBookings != null)
              _buildInfoRow(
                'Total Bookings',
                booking.user.totalBookings.toString(),
              ),
          ]),

          const SizedBox(height: 16),

          // Vendor information
          _buildSectionCard('Vendor Information', Icons.store, [
            _buildInfoRow('Business', booking.vendor.displayName),
            _buildInfoRow('Email', booking.vendor.email),
            if (booking.vendor.phone != null)
              _buildInfoRow('Phone', booking.vendor.phone!),
            if (booking.vendor.totalBookings != null)
              _buildInfoRow(
                'Total Bookings',
                booking.vendor.totalBookings.toString(),
              ),
          ]),

          const SizedBox(height: 16),

          // Booking details
          _buildSectionCard('Booking Details', Icons.event, [
            _buildInfoRow('Service ID', booking.serviceId.toString()),
            _buildInfoRow(
              'Scheduled',
              DateFormat(
                'EEEE, MMMM d, y - h:mm a',
              ).format(booking.scheduledAt),
            ),
            if (booking.estimatedEndAt != null)
              _buildInfoRow(
                'Estimated End',
                DateFormat('h:mm a').format(booking.estimatedEndAt!),
              ),
            _buildInfoRow(
              'Created',
              DateFormat('MMMM d, y - h:mm a').format(booking.createdAt),
            ),
            _buildInfoRow(
              'Last Updated',
              DateFormat('MMMM d, y - h:mm a').format(booking.updatedAt),
            ),
            if (booking.idempotencyKey != null)
              _buildInfoRow('Idempotency Key', booking.idempotencyKey!),
          ]),

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(booking.status, canUpdate: canUpdate),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final color = Color(int.parse(status.colorHex.replaceFirst('#', '0xFF')));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BookingStatus status, {required bool canUpdate}) {
    final canComplete =
        status == BookingStatus.paid || status == BookingStatus.scheduled;
    final canCancel =
        status != BookingStatus.completed && status != BookingStatus.canceled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canUpdate && canComplete)
          ElevatedButton.icon(
            onPressed: _completeBooking,
            icon: const Icon(Icons.check_circle),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        if (canComplete && canCancel) const SizedBox(height: 12),
        if (canUpdate && canCancel)
          OutlinedButton.icon(
            onPressed: _cancelBooking,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Booking'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.all(16),
            ),
          ),
        const SizedBox(height: 12),
        if (canUpdate)
          TextButton.icon(
            onPressed: _addNotes,
            icon: const Icon(Icons.note_add),
            label: const Text('Add Admin Notes'),
            style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
      ],
    );
  }

  Widget _buildErrorView(Object error) {
    String errorMessage = 'Failed to load booking details';
    if (error is BookingNotFoundException) {
      errorMessage = 'Booking #${error.bookingId} not found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
