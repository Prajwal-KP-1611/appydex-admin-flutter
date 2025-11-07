import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import 'job_poller.dart';

/// Button that triggers an export and shows job progress
class ExportButton extends ConsumerStatefulWidget {
  const ExportButton({
    required this.label,
    required this.endpoint,
    required this.exportData,
    this.icon = Icons.download,
    this.variant = ExportButtonVariant.outlined,
    this.onExportStarted,
    this.onExportComplete,
    super.key,
  });

  final String label;
  final String endpoint;
  final Map<String, dynamic> exportData;
  final IconData icon;
  final ExportButtonVariant variant;
  final void Function(String jobId)? onExportStarted;
  final void Function(JobResult result)? onExportComplete;

  @override
  ConsumerState<ExportButton> createState() => _ExportButtonState();
}

enum ExportButtonVariant {
  filled,
  outlined,
  text,
}

class _ExportButtonState extends ConsumerState<ExportButton> {
  String? _activeJobId;
  bool _isInitiating = false;

  Future<void> _startExport() async {
    setState(() => _isInitiating = true);

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.postIdempotent<Map<String, dynamic>>(
        widget.endpoint,
        data: widget.exportData,
      );

      final jobId = response.data?['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        throw Exception('No job_id in export response');
      }

      setState(() {
        _activeJobId = jobId;
        _isInitiating = false;
      });

      widget.onExportStarted?.call(jobId);
    } catch (e) {
      setState(() => _isInitiating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start export: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleComplete(JobResult result) {
    widget.onExportComplete?.call(result);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Export completed!'),
          action: result.hasDownload
              ? SnackBarAction(
                  label: 'Download',
                  onPressed: () {
                    // TODO: Open download URL
                    debugPrint('Download: ${result.downloadUrl}');
                  },
                )
              : null,
        ),
      );
    }
  }

  void _handleError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeJobId != null) {
      return JobPoller(
        jobId: _activeJobId!,
        onComplete: _handleComplete,
        onError: _handleError,
        builder: (context, result) {
          if (result == null) {
            return _buildButton(
              isLoading: true,
              label: 'Starting...',
            );
          }

          if (result.isComplete) {
            // Reset after completion
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() => _activeJobId = null);
              }
            });
            return _buildButton(
              icon: result.status == JobStatus.succeeded
                  ? Icons.check
                  : Icons.error_outline,
              label: result.status == JobStatus.succeeded
                  ? 'Completed'
                  : 'Failed',
              isDisabled: true,
            );
          }

          return _buildButton(
            isLoading: true,
            label: result.progressPercent != null
                ? '${result.progressPercent}%'
                : 'Processing...',
          );
        },
      );
    }

    return _buildButton(
      onPressed: _startExport,
      isLoading: _isInitiating,
      label: _isInitiating ? 'Starting...' : widget.label,
    );
  }

  Widget _buildButton({
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    required String label,
  }) {
    final effectiveIcon = icon ?? widget.icon;
    final effectiveOnPressed = isDisabled ? null : onPressed;

    switch (widget.variant) {
      case ExportButtonVariant.filled:
        return FilledButton.icon(
          onPressed: effectiveOnPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(effectiveIcon),
          label: Text(label),
        );
      case ExportButtonVariant.outlined:
        return OutlinedButton.icon(
          onPressed: effectiveOnPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(effectiveIcon),
          label: Text(label),
        );
      case ExportButtonVariant.text:
        return TextButton.icon(
          onPressed: effectiveOnPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(effectiveIcon),
          label: Text(label),
        );
    }
  }
}
