import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generate a unique idempotency key for mutation requests.
///
/// As per the spec, all POST/PATCH/DELETE operations that modify state
/// should include an Idempotency-Key header to prevent duplicate operations
/// when requests are retried.
String generateIdempotencyKey() => _uuid.v4();

/// Extension to easily add idempotency to Dio request options.
///
/// Usage:
/// ```dart
/// await apiClient.requestAdmin(
///   '/admin/vendors/$id/verify',
///   method: 'POST',
///   options: Options(extra: {}.withIdempotency()),
/// );
/// ```
extension IdempotentOptions on Map<String, dynamic> {
  Map<String, dynamic> withIdempotency() {
    return {...this, 'idempotencyKey': generateIdempotencyKey()};
  }
}

/// Create Options with idempotency key for mutating operations.
Options idempotentOptions({
  Map<String, dynamic>? headers,
  Map<String, dynamic>? extra,
}) {
  return Options(
    headers: headers,
    extra: {...?extra, 'idempotencyKey': generateIdempotencyKey()},
  );
}
