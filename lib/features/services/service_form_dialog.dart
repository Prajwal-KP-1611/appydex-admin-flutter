import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/toast_service.dart';
import '../../core/utils/validators.dart';
import '../../core/api_client.dart';
import '../../models/service.dart';
import '../../repositories/service_repo.dart';

/// Dialog for creating or editing a service
class ServiceFormDialog extends ConsumerStatefulWidget {
  const ServiceFormDialog({super.key, this.service});

  final Service? service;

  @override
  ConsumerState<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends ConsumerState<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vendorIdController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: 'unit');

  bool _isActive = true;
  bool _isLoading = false;
  List<ServiceCategory> _categories = [];
  bool _isGlobalTemplate = true; // Global service (no vendor association)

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // Populate fields if editing
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description ?? '';
      _categoryController.text = widget.service!.category;
      _vendorIdController.text = widget.service!.vendorId.toString();
      _priceController.text = (widget.service!.priceCents / 100)
          .toStringAsFixed(2);
      _unitController.text = widget.service!.unit;
      _isActive = widget.service!.isActive;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final repository = ref.read(serviceRepositoryProvider);
      final categories = await repository.listCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (error) {
      if (mounted) {
        ToastService.showError(
          context,
          'Failed to load categories. Using mock categories for now. (${error.runtimeType})',
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vendorIdController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Service' : 'Create Service'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template toggle
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Global service (available to all vendors)',
                  ),
                  subtitle: const Text(
                    'Enable this to create a catalog service that vendors can choose during onboarding.',
                  ),
                  value: _isGlobalTemplate,
                  onChanged: (value) {
                    setState(() => _isGlobalTemplate = value);
                  },
                ),
                const SizedBox(height: 8),

                // Vendor ID (only when not a global template)
                if (!_isGlobalTemplate) ...[
                  TextFormField(
                    controller: _vendorIdController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor ID *',
                      hintText: 'Enter vendor id (integer)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (_isGlobalTemplate) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Vendor ID is required';
                      }
                      return int.tryParse(v.trim()) == null
                          ? 'Vendor ID must be an integer'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this service offers',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (v) =>
                      Validators.maxLength(v, 2000, fieldName: 'Description'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g., Emergency Pipe Repair',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.combine([
                    (value) => Validators.required(value, fieldName: 'Title'),
                    (value) =>
                        Validators.maxLength(value, 150, fieldName: 'Title'),
                  ]),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                // Category (type to create new or choose existing)
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category (type or pick) *',
                    border: const OutlineInputBorder(),
                    helperText: _categories.isNotEmpty
                        ? 'Existing: ${_categories.map((e) => e.name).take(6).join(', ')}${_categories.length > 6 ? ', ...' : ''}'
                        : null,
                  ),
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Category'),
                ),
                const SizedBox(height: 16),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (e.g., 150.00) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Price is required';
                    }
                    return double.tryParse(v.trim()) == null
                        ? 'Enter a valid number'
                        : null;
                  },
                ),
                const SizedBox(height: 16),

                // Unit
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Active Toggle
                SwitchListTile(
                  title: const Text('Active (visible to users)'),
                  subtitle: Text(
                    _isActive
                        ? 'Service is visible in the app'
                        : 'Service is hidden from users',
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text.trim());
      final vendorIdValue = _isGlobalTemplate
          ? 0
          : (int.tryParse(_vendorIdController.text.trim()) ?? 0);

      final request = ServiceRequest(
        vendorId: vendorIdValue,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        priceCents: (price * 100).round(),
        unit: _unitController.text.trim().isEmpty
            ? 'unit'
            : _unitController.text.trim(),
      );

      if (widget.service != null) {
        // Update existing service
        await ref
            .read(servicesProvider.notifier)
            .update(widget.service!.id, request);
        if (mounted) {
          ToastService.showSuccess(context, 'Service updated successfully');
          Navigator.pop(context);
        }
      } else {
        // Create new service
        await ref.read(servicesProvider.notifier).create(request);
        if (mounted) {
          ToastService.showSuccess(context, 'Service created successfully');
          Navigator.pop(context);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Try to surface validation details if present
        String message =
            'Failed to ${widget.service != null ? 'update' : 'create'} service: $error';
        try {
          final err = error;
          if (err is DioException && err.error is AppHttpException) {
            final app = err.error as AppHttpException;
            if (app.details != null && app.details!['detail'] is List) {
              final details = app.details!['detail'] as List;
              final lines = details
                  .map((e) => e is Map ? e.values.join(': ') : e.toString())
                  .take(5)
                  .join('\n');
              message = '${app.message}\n$lines';
            } else {
              message = app.message;
            }
          }
        } catch (_) {}
        ToastService.showError(context, message);
      }
    }
  }
}
