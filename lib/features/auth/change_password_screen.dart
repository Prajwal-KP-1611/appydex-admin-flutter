import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../core/utils/validators.dart';

/// Screen shown when user must change their password
/// (e.g., first login with default credentials)
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.dio.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        // Password changed successfully
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );

          // Navigate to dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } catch (e) {
      setState(() {
        if (e is DioException) {
          final error = e.error;
          if (error is AppHttpException) {
            _error = error.message;
          } else {
            _error = 'Failed to change password. Please try again.';
          }
        } else {
          _error = 'An unexpected error occurred. Please try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundNeutralGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      const Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: AppTheme.warningAmber,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Change Password Required',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'For security reasons, you must change your password before continuing.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDarkSlate.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Error message
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.dangerRed.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.dangerRed,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppTheme.dangerRed,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Current Password
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          hintText: 'Enter your current password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.75),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                            tooltip: _obscureCurrentPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        validator: (value) => Validators.required(
                          value,
                          fieldName: 'Current password',
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // New Password
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 22,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.75),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            tooltip: _obscureNewPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        obscureText: _obscureNewPassword,
                        validator: Validators.password,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 8),

                      // Password requirements
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password requirements:',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            _buildRequirement('At least 8 characters'),
                            _buildRequirement('One uppercase letter'),
                            _buildRequirement('One lowercase letter'),
                            _buildRequirement('One number'),
                            _buildRequirement(
                              'One special character (!@#\$%^&*)',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          hintText: 'Re-enter your new password',
                          prefixIcon: const Icon(Icons.lock),
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
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Change Password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppTheme.accentEmerald,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
