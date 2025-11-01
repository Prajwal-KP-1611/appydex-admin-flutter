import 'dart:io';

import 'dns_utils.dart';

Future<DnsLookupResult> lookupHost(String host) async {
  final stopwatch = Stopwatch()..start();
  final addresses = await InternetAddress.lookup(host);
  stopwatch.stop();
  return DnsLookupResult(
    success: addresses.isNotEmpty,
    addresses: addresses.map((e) => e.address).toList(),
    latency: stopwatch.elapsed,
  );
}
