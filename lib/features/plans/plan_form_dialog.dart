import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/toast_service.dart';
import '../../core/utils/validators.dart';
import '../../models/plan.dart';
import '../../repositories/plan_repo.dart';

/// Dialog for creating or editing subscription plans
class PlanFormDialog extends ConsumerStatefulWidget {
  const PlanFormDialog({super.key, this.plan});

  final Plan? plan;

  @override
  ConsumerState<PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends ConsumerState<PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _trialDaysController = TextEditingController(text: '0');
  final _promoDaysController = TextEditingController(text: '0');

  bool _isLoading = false;
  String _durationType = 'monthly';

  @override
  void initState() {
    super.initState();

    if (widget.plan != null) {
      _codeController.text = widget.plan!.code;
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description ?? '';
      _priceController.text = (widget.plan!.priceCents / 100).toStringAsFixed(
        2,
      );
      _durationController.text = widget.plan!.durationDays.toString();
      _trialDaysController.text = widget.plan!.trialDays?.toString() ?? '0';
      _promoDaysController.text = widget.plan!.promoDays?.toString() ?? '0';

      // Set duration type based on days
      if (widget.plan!.durationDays == 30) {
        _durationType = 'monthly';
      } else if (widget.plan!.durationDays == 365) {
        _durationType = 'yearly';
      } else {
        _durationType = 'custom';
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _trialDaysController.dispose();
    _promoDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.plan != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Plan' : 'Create Plan'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Code
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Code *',
                    hintText: 'e.g., prof_monthly',
                    border: OutlineInputBorder(),
                    helperText: 'Unique identifier for this plan',
                  ),
                  validator: Validators.combine([
                    (value) => Validators.required(value, fieldName: 'Code'),
                    (value) =>
                        Validators.maxLength(value, 50, fieldName: 'Code'),
                  ]),
                  enabled: !isEditing, // Code cannot be changed after creation
                ),
                const SizedBox(height: 16),

                // Plan Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Name *',
                    hintText: 'e.g., Professional',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.combine([
                    (value) => Validators.required(value, fieldName: 'Name'),
                    (value) =>
                        Validators.maxLength(value, 100, fieldName: 'Name'),
                  ]),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this plan offers',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) =>
                      Validators.maxLength(v, 500, fieldName: 'Description'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    hintText: '49.99',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null) {
                      return 'Enter a valid price';
                    }
                    if (price < 0) {
                      return 'Price cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Billing Period Type
                const Text(
                  'Billing Period *',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Monthly'),
                        subtitle: const Text('30 days'),
                        value: 'monthly',
                        groupValue: _durationType,
                        onChanged: (value) {
                          setState(() {
                            _durationType = value!;
                            _durationController.text = '30';
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Yearly'),
                        subtitle: const Text('365 days'),
                        value: 'yearly',
                        groupValue: _durationType,
                        onChanged: (value) {
                          setState(() {
                            _durationType = value!;
                            _durationController.text = '365';
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Custom'),
                        value: 'custom',
                        groupValue: _durationType,
                        onChanged: (value) {
                          setState(() {
                            _durationType = value!;
                            _durationController.clear();
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                if (_durationType == 'custom') ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Duration (days) *',
                      hintText: 'e.g., 90',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Duration is required';
                      }
                      final days = int.tryParse(value.trim());
                      if (days == null || days <= 0) {
                        return 'Enter a valid number of days';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Trial Days
                TextFormField(
                  controller: _trialDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Trial Days',
                    hintText: 'e.g., 14 (default: 0)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final days = int.tryParse(value.trim());
                    if (days == null || days < 0) {
                      return 'Enter a valid number of days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Promo Days
                TextFormField(
                  controller: _promoDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Promo Days (Bonus)',
                    hintText: 'e.g., 7 (default: 0)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final days = int.tryParse(value.trim());
                    if (days == null || days < 0) {
                      return 'Enter a valid number of days';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ToastService.showError(
        context,
        'Please fix the validation errors before submitting',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final durationDays = int.parse(_durationController.text.trim());
      final trialDays = _trialDaysController.text.trim().isEmpty
          ? 0
          : int.parse(_trialDaysController.text.trim());
      final promoDays = _promoDaysController.text.trim().isEmpty
          ? 0
          : int.parse(_promoDaysController.text.trim());

      final request = PlanRequest(
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priceCents: (price * 100).round(),
        durationDays: durationDays,
        trialDays: trialDays,
        promoDays: promoDays,
      );

      if (widget.plan != null) {
        // Update existing plan
        await ref.read(plansProvider.notifier).update(widget.plan!.id, request);
        if (mounted) {
          ToastService.showSuccess(context, 'Plan updated successfully');
          Navigator.pop(context);
        }
      } else {
        // Create new plan
        await ref.read(plansProvider.notifier).create(request);
        if (mounted) {
          ToastService.showSuccess(context, 'Plan created successfully');
          Navigator.pop(context);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastService.showError(
          context,
          'Failed to ${widget.plan != null ? 'update' : 'create'} plan: $error',
        );
      }
    }
  }
}
