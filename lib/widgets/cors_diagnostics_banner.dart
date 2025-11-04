import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Banner shown when a DELETE request fails on web (likely CORS issue).
/// Provides a copyable preflight curl command for backend debugging.
class CORSDiagnosticsBanner extends StatelessWidget {
  const CORSDiagnosticsBanner({
    super.key,
    required this.method,
    required this.url,
    required this.headers,
  });

  final String method;
  final String url;
  final Map<String, dynamic> headers;

  String _generatePreflightCurl() {
    // Extract origin from browser (if on web, use current origin)
    final origin = kIsWeb ? Uri.base.origin : 'http://localhost:46633';

    // Build header list for Access-Control-Request-Headers
    final headerNames = headers.keys
        .where((k) => k.toLowerCase() != 'content-length')
        .map((k) => k.toLowerCase())
        .join(',');

    return '''curl -i -X OPTIONS \\
  '$url' \\
  -H 'Origin: $origin' \\
  -H 'Access-Control-Request-Method: $method' \\
  -H 'Access-Control-Request-Headers: $headerNames'
''';
  }

  void _copyCurl(BuildContext context) {
    final curl = _generatePreflightCurl();
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preflight curl copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CORS Preflight Failure (Web)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'DELETE request failed before reaching the backend. This is likely a CORS issue.',
            style: TextStyle(color: Colors.orange.shade900),
          ),
          const SizedBox(height: 8),
          Text(
            'Backend needs to allow DELETE from origin: ${kIsWeb ? Uri.base.origin : "http://localhost:46633"}',
            style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _copyCurl(context),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Preflight Curl'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Share with backend team',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
