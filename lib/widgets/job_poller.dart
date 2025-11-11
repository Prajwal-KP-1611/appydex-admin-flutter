import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api_client.dart';

/// Status of a long-running job
enum JobStatus {
  pending,
  processing,
  succeeded,
  failed,
  unknown;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => JobStatus.unknown,
    );
  }
}

/// Job result model
class JobResult {
  const JobResult({
    required this.id,
    required this.type,
    required this.status,
    this.progressPercent,
    required this.createdAt,
    this.completedAt,
    this.downloadUrl,
    this.expiresAt,
    this.error,
  });

  final String id;
  final String type;
  final JobStatus status;
  final int? progressPercent;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? downloadUrl;
  final DateTime? expiresAt;
  final String? error;

  factory JobResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    return JobResult(
      id: json['id'] as String,
      type: json['type'] as String,
      status: JobStatus.fromString(json['status'] as String),
      progressPercent: json['progress_percent'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      downloadUrl: result?['download_url'] as String?,
      expiresAt: result?['expires_at'] != null
          ? DateTime.parse(result!['expires_at'] as String)
          : null,
      error: json['error'] as String?,
    );
  }

  bool get isComplete =>
      status == JobStatus.succeeded || status == JobStatus.failed;
  bool get hasDownload => downloadUrl != null && downloadUrl!.isNotEmpty;
}

/// Widget that polls a job until completion and shows progress/result
class JobPoller extends ConsumerStatefulWidget {
  const JobPoller({
    required this.jobId,
    this.onComplete,
    this.onError,
    this.builder,
    this.initialInterval = const Duration(seconds: 2),
    this.maxInterval = const Duration(seconds: 10),
    this.maxAttempts = 60,
    super.key,
  });

  final String jobId;
  final void Function(JobResult result)? onComplete;
  final void Function(String error)? onError;
  final Widget Function(BuildContext context, JobResult? result)? builder;
  final Duration initialInterval;
  final Duration maxInterval;
  final int maxAttempts;

  @override
  ConsumerState<JobPoller> createState() => _JobPollerState();
}

class _JobPollerState extends ConsumerState<JobPoller> {
  Timer? _timer;
  JobResult? _currentResult;
  int _attempts = 0;
  Duration _currentInterval = const Duration(seconds: 2);
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentInterval = widget.initialInterval;
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollOnce();
  }

  Future<void> _pollOnce() async {
    if (_attempts >= widget.maxAttempts) {
      setState(() {
        _error = 'Job polling timed out after ${widget.maxAttempts} attempts';
      });
      widget.onError?.call(_error!);
      return;
    }

    _attempts++;

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.requestAdmin<Map<String, dynamic>>(
        '/admin/jobs/${widget.jobId}',
        method: 'GET',
      );

      final result = JobResult.fromJson(response.data!);
      setState(() {
        _currentResult = result;
        _error = null;
      });

      if (result.isComplete) {
        if (result.status == JobStatus.succeeded) {
          widget.onComplete?.call(result);
        } else if (result.status == JobStatus.failed) {
          final errorMsg = result.error ?? 'Job failed';
          setState(() => _error = errorMsg);
          widget.onError?.call(errorMsg);
        }
      } else {
        // Schedule next poll with exponential backoff
        _scheduleNextPoll();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to check job status: $e';
      });
      // Retry on network errors
      _scheduleNextPoll();
    }
  }

  void _scheduleNextPoll() {
    // Exponential backoff: double interval each time, up to maxInterval
    _currentInterval = Duration(
      milliseconds: math.min(
        _currentInterval.inMilliseconds * 2,
        widget.maxInterval.inMilliseconds,
      ),
    );

    _timer?.cancel();
    _timer = Timer(_currentInterval, _pollOnce);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _currentResult);
    }

    // Default UI
    if (_error != null) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentResult == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Starting job...'),
            ],
          ),
        ),
      );
    }

    final result = _currentResult!;

    if (result.isComplete) {
      if (result.status == JobStatus.succeeded) {
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Job completed!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (result.hasDownload) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Download ready (expires ${_formatExpiry(result.expiresAt)})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (result.hasDownload)
                  FilledButton.icon(
                    onPressed: () => _downloadFile(result.downloadUrl!),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
              ],
            ),
          ),
        );
      } else {
        return Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.error ?? 'Job failed',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // In progress
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: result.progressPercent != null
                    ? result.progressPercent! / 100
                    : null,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result.status == JobStatus.processing
                        ? 'Processing...'
                        : 'Pending...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (result.progressPercent != null)
                    Text(
                      '${result.progressPercent}% complete',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final duration = expiresAt.difference(DateTime.now());
    if (duration.inHours > 0) {
      return 'in ${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return 'in ${duration.inMinutes}m';
    } else {
      return 'soon';
    }
  }

  void _downloadFile(String url) {
    // On web, open in new tab
    // ignore: avoid_web_libraries_in_flutter
    // html.window.open(url, '_blank');

    // For now, just show snackbar with URL
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download URL: $url'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}
