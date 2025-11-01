import 'dns_utils.dart';

Future<DnsLookupResult> lookupHost(String host) async {
  return DnsLookupResult(
    success: false,
    addresses: const [],
    latency: Duration.zero,
    message: 'DNS lookup not supported on this platform.',
  );
}
