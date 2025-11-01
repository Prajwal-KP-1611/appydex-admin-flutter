class AdminEndpointMissing implements Exception {
  AdminEndpointMissing(this.endpoint);

  final String endpoint;

  @override
  String toString() => 'AdminEndpointMissing($endpoint)';
}
