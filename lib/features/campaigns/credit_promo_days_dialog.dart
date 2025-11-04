import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/toast_service.dart';
import '../../repositories/campaign_repo.dart';

/// Dialog for manually crediting promo days to vendors
class CreditPromoDaysDialog extends ConsumerStatefulWidget {
  const CreditPromoDaysDialog({super.key});

  @override
  ConsumerState<CreditPromoDaysDialog> createState() =>
      _CreditPromoDaysDialogState();
}

class _CreditPromoDaysDialogState extends ConsumerState<CreditPromoDaysDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vendorIdController = TextEditingController();
  final _daysController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _campaignType = 'admin_compensation';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _vendorIdController.dispose();
    _daysController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Credit Promo Days'),
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
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manually credit promotional days to a vendor account.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Vendor ID field
                TextFormField(
                  controller: _vendorIdController,
                  decoration: const InputDecoration(
                    labelText: 'Vendor ID *',
                    hintText: 'Enter vendor ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a vendor ID';
                    }
                    final id = int.tryParse(value);
                    if (id == null || id <= 0) {
                      return 'Please enter a valid vendor ID';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Days field
                TextFormField(
                  controller: _daysController,
                  decoration: const InputDecoration(
                    labelText: 'Days to Credit *',
                    hintText: 'Enter number of days',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                    helperText: 'Must be between 1 and 365 days',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter number of days';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days <= 0) {
                      return 'Days must be greater than 0';
                    }
                    if (days > 365) {
                      return 'Days cannot exceed 365';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campaign type dropdown
                DropdownButtonFormField<String>(
                  value: _campaignType,
                  decoration: const InputDecoration(
                    labelText: 'Campaign Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin_compensation',
                      child: Text('Admin Compensation'),
                    ),
                    DropdownMenuItem(
                      value: 'signup_bonus',
                      child: Text('Signup Bonus'),
                    ),
                    DropdownMenuItem(
                      value: 'referral_bonus',
                      child: Text('Referral Bonus'),
                    ),
                    DropdownMenuItem(
                      value: 'promotional_credit',
                      child: Text('Promotional Credit'),
                    ),
                    DropdownMenuItem(
                      value: 'service_recovery',
                      child: Text('Service Recovery'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _campaignType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional notes about this credit',
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
          onPressed: _isSubmitting ? null : _handleSubmit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Credit Days'),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final vendorId = int.parse(_vendorIdController.text.trim());
      final days = int.parse(_daysController.text.trim());
      final description = _descriptionController.text.trim();

      await ref
          .read(promoLedgerProvider.notifier)
          .creditDays(
            vendorId: vendorId,
            days: days,
            campaignType: _campaignType,
            description: description.isEmpty ? null : description,
          );

      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(
          context,
          '$days promo day(s) credited to vendor #$vendorId',
        );
      }
    } catch (error) {
      if (mounted) {
        ToastService.showError(context, 'Failed to credit promo days: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
