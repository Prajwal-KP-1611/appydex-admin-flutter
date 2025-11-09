import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Dialog for deleting users with multiple deletion types
///
/// Supports three deletion types:
/// - Soft Delete: Suspends account (reversible)
/// - Anonymize: GDPR-compliant data removal (irreversible)
/// - Hard Delete: Permanent removal (test data only, < 7 days)
class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.createdAt,
    super.key,
  });

  final int userId;
  final String userName;
  final String userEmail;
  final DateTime? createdAt;

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  int _currentStep = 0;
  String? _selectedDeletionType;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hardDeleteConfirmed = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _canProceedToNextStep {
    if (_currentStep == 0) {
      return _selectedDeletionType != null;
    } else if (_currentStep == 1) {
      return _reasonController.text.trim().length >= 10;
    }
    return true;
  }

  bool get _isTestData {
    if (widget.createdAt == null) return false;
    final daysSinceCreation = DateTime.now()
        .difference(widget.createdAt!)
        .inDays;
    return daysSinceCreation < 7;
  }

  String get _deletionTypeTitle {
    switch (_selectedDeletionType) {
      case 'soft':
        return 'Suspend Account';
      case 'anonymize':
        return 'Anonymize Data (GDPR)';
      case 'hard':
        return 'Permanent Deletion';
      default:
        return '';
    }
  }

  String get _deletionTypeDescription {
    switch (_selectedDeletionType) {
      case 'soft':
        return 'User will be suspended and can be restored later. All data is preserved.';
      case 'anonymize':
        return 'User data will be permanently anonymized for GDPR compliance. This action cannot be undone.';
      case 'hard':
        return 'User and all associated data will be permanently deleted. This action cannot be undone.';
      default:
        return '';
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        }
      });
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'deletion_type': _selectedDeletionType,
        'reason': _reasonController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.red.shade200, width: 2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete User Account',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),

            // Stepper
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Type', _currentStep >= 0),
                  Expanded(child: _buildStepLine(_currentStep >= 1)),
                  _buildStepIndicator(1, 'Reason', _currentStep >= 1),
                  Expanded(child: _buildStepLine(_currentStep >= 2)),
                  _buildStepIndicator(2, 'Confirm', _currentStep >= 2),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(key: _formKey, child: _buildStepContent()),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  Row(
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _previousStep,
                          child: const Text('Back'),
                        ),
                      const SizedBox(width: 8),
                      if (_currentStep < 2)
                        ElevatedButton(
                          onPressed: _canProceedToNextStep ? _nextStep : null,
                          child: const Text('Next'),
                        ),
                      if (_currentStep == 2)
                        ElevatedButton(
                          onPressed:
                              (_selectedDeletionType == 'hard' &&
                                  !_hardDeleteConfirmed)
                              ? null
                              : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Delete ${_deletionTypeTitle}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final theme = Theme.of(context);
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent
                ? AppTheme.primaryDeepBlue
                : theme.disabledColor.withOpacity(0.2),
            border: Border.all(
              color: isCompleted || isCurrent
                  ? AppTheme.primaryDeepBlue
                  : theme.disabledColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : theme.disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppTheme.primaryDeepBlue : theme.disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    final theme = Theme.of(context);
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isActive
          ? AppTheme.primaryDeepBlue
          : theme.disabledColor.withOpacity(0.3),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDeletionTypeStep();
      case 1:
        return _buildReasonStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDeletionTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Deletion Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you want to handle this user\'s data.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        // Soft Delete
        _buildDeletionTypeCard(
          type: 'soft',
          title: 'Suspend Account',
          description:
              'Temporarily suspend the user account. Can be restored later.',
          icon: Icons.pause_circle_outline,
          iconColor: Colors.orange,
          features: [
            'User cannot login',
            'All data preserved',
            'Can be restored',
            'Bookings remain active',
          ],
        ),
        const SizedBox(height: 16),

        // Anonymize
        _buildDeletionTypeCard(
          type: 'anonymize',
          title: 'Anonymize (GDPR)',
          description:
              'Permanently anonymize user data for GDPR compliance. Cannot be undone.',
          icon: Icons.privacy_tip_outlined,
          iconColor: Colors.blue,
          features: [
            'Personal data removed',
            'GDPR compliant',
            'Cannot be restored',
            'Transaction history preserved',
          ],
        ),
        const SizedBox(height: 16),

        // Hard Delete
        _buildDeletionTypeCard(
          type: 'hard',
          title: 'Permanent Delete',
          description:
              'Completely remove user and all data. Only for test accounts < 7 days old.',
          icon: Icons.delete_forever,
          iconColor: Colors.red,
          features: [
            'Complete data removal',
            'Cannot be restored',
            'Only for test data',
            'All bookings deleted',
          ],
          isDisabled: !_isTestData,
          disabledReason: !_isTestData
              ? 'Account is older than 7 days. Use Anonymize for GDPR compliance.'
              : null,
        ),
      ],
    );
  }

  Widget _buildDeletionTypeCard({
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    bool isDisabled = false,
    String? disabledReason,
  }) {
    final isSelected = _selectedDeletionType == type;
    final theme = Theme.of(context);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                setState(() {
                  _selectedDeletionType = type;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? iconColor : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? iconColor.withOpacity(0.05) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: iconColor, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(feature, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (isDisabled && disabledReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          disabledReason,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deletion Reason',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please provide a detailed reason for this deletion. This will be logged for audit purposes.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _reasonController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: 'Reason for deletion',
            hintText: 'Enter a detailed reason (minimum 10 characters)...',
            border: const OutlineInputBorder(),
            helperText: 'Minimum 10 characters required',
            counterText: '${_reasonController.text.length}/500',
          ),
          validator: (value) {
            if (value == null || value.trim().length < 10) {
              return 'Reason must be at least 10 characters';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {}); // Update character count
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    final theme = Theme.of(context);
    final isHardDelete = _selectedDeletionType == 'hard';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Deletion',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review the details before proceeding.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),

        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.userEmail,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                'Deletion Type',
                _deletionTypeTitle,
                Icons.delete_outline,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Description',
                _deletionTypeDescription,
                Icons.info_outline,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Reason',
                _reasonController.text.trim(),
                Icons.notes,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Hard delete confirmation
        if (isHardDelete) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.red.shade900,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DANGER: Permanent Deletion',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This action will permanently delete all user data and cannot be undone. All bookings, payments, and history will be completely removed from the database.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _hardDeleteConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _hardDeleteConfirmed = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'I understand this action is permanent and cannot be undone',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
