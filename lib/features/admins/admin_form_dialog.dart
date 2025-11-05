import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/utils/toast_service.dart';
import '../../core/utils/validators.dart';
import '../../models/admin_role.dart';
import '../../models/admin_user.dart';
import '../../repositories/admin_user_repo.dart';

/// Dialog for creating or editing admin users
class AdminFormDialog extends ConsumerStatefulWidget {
  const AdminFormDialog({super.key, this.admin});

  final AdminUser? admin;

  @override
  ConsumerState<AdminFormDialog> createState() => _AdminFormDialogState();
}

class _AdminFormDialogState extends ConsumerState<AdminFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AdminRole _selectedRole = AdminRole.vendorAdmin;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool get _isEditing => widget.admin != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final admin = widget.admin!;
      _emailController.text = admin.email;
      _nameController.text = admin.name ?? '';
      _selectedRole = admin.roles.isNotEmpty
          ? admin.roles.first
          : AdminRole.vendorAdmin;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Show validation error message
      if (mounted) {
        ToastService.showError(
          context,
          'Please fix the validation errors before submitting',
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // UPDATE: Only send email, name, and password (if provided)
        // Role changes must be done via separate role management endpoints
        final updateRequest = AdminUserUpdateRequest(
          email: _emailController.text.trim(),
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          // Only include password if it was actually entered
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
        );

        await ref
            .read(adminUsersProvider.notifier)
            .updateUser(widget.admin!.id, updateRequest);
      } else {
        // CREATE: Send all required fields including role
        final createRequest = AdminUserRequest(
          email: _emailController.text.trim(),
          name: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
          password: _passwordController.text,
          role: _selectedRole.value,
        );

        await ref.read(adminUsersProvider.notifier).createUser(createRequest);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            'Failed to ${_isEditing ? 'update' : 'create'} admin';

        // Extract AppHttpException from DioException wrapper
        AppHttpException? httpException;
        if (e is DioException && e.error is AppHttpException) {
          httpException = e.error as AppHttpException;
        } else if (e is AppHttpException) {
          httpException = e;
        }

        if (httpException != null) {
          // Extract detailed validation errors if available
          if (httpException.statusCode == 401) {
            errorMessage = '🔒 Session expired. Please login again.';
          } else if (httpException.statusCode == 403) {
            errorMessage =
                '🚫 You don\'t have permission to perform this action.';
          } else if (httpException.statusCode == 422 ||
              httpException.message.toLowerCase().contains('validation')) {
            errorMessage = '❌ Validation Error:\n\n';

            // Check if there are detailed error messages in the details map
            if (httpException.details != null &&
                httpException.details!['detail'] != null) {
              final details = httpException.details!['detail'];
              if (details is List) {
                bool hasAuthError = false;
                for (var error in details) {
                  if (error is Map) {
                    final loc = error['loc'] as List?;
                    final msg = error['msg'] as String?;

                    // Check if this is an Authorization header error
                    if (loc != null &&
                        loc.length >= 2 &&
                        loc[0] == 'header' &&
                        loc[1] == 'Authorization') {
                      hasAuthError = true;
                      break;
                    }

                    final fieldName = loc != null && loc.length > 1
                        ? loc.last.toString()
                        : 'field';
                    errorMessage +=
                        '• $fieldName: ${msg ?? error.toString()}\n';
                  } else {
                    errorMessage += '• $error\n';
                  }
                }

                // If Authorization header is missing, show session expired message
                if (hasAuthError) {
                  errorMessage = '🔒 Session expired. Please login again.';
                }
              } else {
                errorMessage += details.toString();
              }
            } else if (httpException.details != null &&
                httpException.details!.isNotEmpty) {
              httpException.details!.forEach((key, value) {
                if (value is List) {
                  for (var error in value) {
                    errorMessage += '• $key: $error\n';
                  }
                } else {
                  errorMessage += '• $key: $value\n';
                }
              });
            } else {
              // Try to extract field-specific errors from the error string
              final errorStr = httpException.toString().toLowerCase();
              if (errorStr.contains('email')) {
                errorMessage += '• Email: Invalid or already exists\n';
              }
              if (errorStr.contains('password')) {
                errorMessage +=
                    '• Password: Must be at least 8 characters with uppercase, lowercase, number, and special character\n';
              }
              if (errorStr.contains('role')) {
                errorMessage += '• Role: Invalid role selected\n';
              }

              // Fallback to the error message
              if (errorMessage == '❌ Validation Error:\n\n') {
                errorMessage += httpException.message;

                // Show trace ID for debugging
                if (httpException.traceId != null) {
                  errorMessage += '\n\nTrace ID: ${httpException.traceId}';
                }
              }
            }
          } else {
            errorMessage = '❌ ${httpException.message}';
            if (httpException.traceId != null) {
              errorMessage += '\n\nTrace ID: ${httpException.traceId}';
            }
          }
        } else {
          errorMessage = '❌ $errorMessage:\n${e.toString()}';
        }

        ToastService.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? 'Edit Admin User' : 'Create Admin User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form fields
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            hintText: 'admin@appydex.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password (required for create, optional for update)
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: _isEditing
                                ? 'New Password (leave blank to keep current)'
                                : 'Password *',
                            hintText:
                                'Min 8 chars, 1 upper, 1 lower, 1 number, 1 special',
                            helperText: _isEditing
                                ? 'Leave blank to keep current password'
                                : 'Must contain: uppercase, lowercase, number, special char',
                            helperMaxLines: 2,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 22,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.75),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            // For create: password is required
                            if (!_isEditing) {
                              return Validators.password(value);
                            }
                            // For update: only validate if password is provided
                            if (value != null && value.isNotEmpty) {
                              return Validators.password(value);
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Confirm password (only if password is entered)
                        if (!_isEditing || _passwordController.text.isNotEmpty)
                          Column(
                            children: [
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password *',
                                  hintText: 'Re-enter password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 22,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.75),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    tooltip: _obscureConfirmPassword
                                        ? 'Show password'
                                        : 'Hide password',
                                  ),
                                ),
                                obscureText: _obscureConfirmPassword,
                                validator: (value) =>
                                    Validators.confirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                                enabled: !_isLoading,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),

                        // Role (only for create - updates must use role management endpoints)
                        if (!_isEditing) ...[
                          Text(
                            'Role *',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<AdminRole>(
                            initialValue: _selectedRole,
                            decoration: const InputDecoration(
                              hintText: 'Select role',
                              border: OutlineInputBorder(),
                            ),
                            items: AdminRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.displayName),
                              );
                            }).toList(),
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    }
                                  },
                            validator: (value) =>
                                value == null ? 'Please select a role' : null,
                          ),
                        ] else ...[
                          // Show current roles for edit mode (read-only)
                          Text(
                            'Current Roles',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade50,
                            ),
                            child: Text(
                              widget.admin!.roles
                                  .map((r) => r.displayName)
                                  .join(', '),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use Role Management to change roles',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
