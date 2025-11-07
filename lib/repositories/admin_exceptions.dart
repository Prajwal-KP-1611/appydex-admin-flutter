class AdminEndpointMissing implements Exception {
  AdminEndpointMissing(this.endpoint);

  final String endpoint;

  @override
  String toString() => 'AdminEndpointMissing($endpoint)';
}

class AdminValidationError implements Exception {
  AdminValidationError(this.message);

  final String message;

  @override
  String toString() => 'AdminValidationError: $message';
}
