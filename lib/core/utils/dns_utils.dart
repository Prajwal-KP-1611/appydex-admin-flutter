import 'dns_utils_io.dart' if (dart.library.html) 'dns_utils_web.dart' as dns;

class DnsLookupResult {
  const DnsLookupResult({
    required this.success,
    required this.addresses,
    required this.latency,
    this.message,
  });

  final bool success;
  final List<String> addresses;
  final Duration latency;
  final String? message;
}

Future<DnsLookupResult> performDnsLookup(String host) async {
  if (host.isEmpty) {
    return const DnsLookupResult(
      success: false,
      addresses: [],
      latency: Duration.zero,
      message: 'Host was empty.',
    );
  }

  return dns.lookupHost(host);
}
