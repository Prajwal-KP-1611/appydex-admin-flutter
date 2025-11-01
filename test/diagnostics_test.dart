import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appydex_admin/features/diagnostics/diagnostics_controller.dart';

void main() {
  test('buildDiagnosticResult surfaces trace id and 404 hint', () {
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: 'https://api.appydex.co/healthz'),
      statusCode: 404,
      data: {
        'code': 'HTTP_ERROR',
        'message': 'Not Found',
        'trace_id': 'abc-trace',
      },
    );

    final result = buildDiagnosticResult(
      url: response.requestOptions.path,
      response: response,
      error: null,
      latency: const Duration(milliseconds: 120),
    );

    expect(result.statusCode, 404);
    expect(result.traceId, 'abc-trace');
    expect(result.hint, contains('/healthz'));
    expect(result.bodyPreview, contains('HTTP_ERROR'));
    expect(result.latency, const Duration(milliseconds: 120));
  });
}
