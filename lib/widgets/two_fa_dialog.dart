import 'package:flutter/material.dart';

/// Show 2FA confirmation dialog for sensitive admin operations
/// Returns true if the 2FA code is valid, false otherwise
Future<bool> show2FAConfirmDialog({
  required BuildContext context,
  required String operation,
  required Future<bool> Function(String code) onVerify,
}) async {
  final codeController = TextEditingController();
  bool isVerifying = false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 8),
            Text('2FA Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This operation requires two-factor authentication:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                operation,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '000000',
                prefixIcon: Icon(Icons.pin),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              enabled: !isVerifying,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isVerifying ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: isVerifying
                ? null
                : () async {
                    final code = codeController.text.trim();
                    if (code.isEmpty || code.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 6-digit code'),
                        ),
                      );
                      return;
                    }

                    setState(() => isVerifying = true);

                    try {
                      final isValid = await onVerify(code);
                      if (context.mounted) {
                        Navigator.of(context).pop(isValid);
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Verification failed: $error')),
                        );
                        setState(() => isVerifying = false);
                      }
                    }
                  },
            child: isVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
        ],
      ),
    ),
  );

  return result ?? false;
}

/// Wrapper function to execute a sensitive operation with 2FA confirmation
/// Only prompts for 2FA if the user role is 'super_admin'
Future<T?> executeWithAdmin2FA<T>({
  required BuildContext context,
  required String userRole,
  required String operation,
  required Future<bool> Function(String code) verify2FA,
  required Future<T> Function() execute,
}) async {
  // Only require 2FA for super_admin
  if (userRole == 'super_admin') {
    final confirmed = await show2FAConfirmDialog(
      context: context,
      operation: operation,
      onVerify: verify2FA,
    );

    if (!confirmed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation cancelled')),
        );
      }
      return null;
    }
  }

  // Execute the operation
  try {
    return await execute();
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Operation failed: $error')),
      );
    }
    return null;
  }
}
