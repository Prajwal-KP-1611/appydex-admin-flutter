import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SnackBar buildTraceSnackbar(
  String message, {
  String? traceId,
  VoidCallback? onDiagnostics,
  Duration duration = const Duration(seconds: 4),
}) {
  return SnackBar(
    duration: duration,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        if (traceId != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Trace ID: $traceId',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: traceId));
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ],
          ),
        ],
        if (onDiagnostics != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onDiagnostics,
            child: const Text('Open diagnostics'),
          ),
        ],
      ],
    ),
  );
}
