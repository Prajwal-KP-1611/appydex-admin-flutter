import 'package:flutter/material.dart';

import '../theme.dart';

/// Toast notification utility for consistent UI feedback
class ToastService {
  const ToastService._();

  /// Show success toast
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error toast
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.dangerRed,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning toast
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppTheme.textDarkSlate),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppTheme.textDarkSlate),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningAmber,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info toast
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.secondarySkyBlue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading toast (non-dismissible)
  static void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: AppTheme.textDarkSlate,
        duration: const Duration(minutes: 5), // Long duration
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hide current toast
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
