/// Generates a CSV string from a list of row maps.
String toCsv(List<Map<String, dynamic>> rows, {List<String>? columns}) {
  if (rows.isEmpty) {
    final header = columns ?? const [];
    return header.isEmpty ? '' : '${header.join(',')}\n';
  }

  final resolvedColumns =
      columns ?? rows.expand((row) => row.keys).toSet().toList();

  final buffer = StringBuffer();
  buffer.writeln(_toCsvRow(resolvedColumns));

  for (final row in rows) {
    final values = resolvedColumns.map(
      (column) => row.containsKey(column) ? row[column] : null,
    );
    buffer.writeln(_toCsvRow(values));
  }

  return buffer.toString();
}

String _toCsvRow(Iterable<dynamic> values) {
  return values.map(_escapeCsvValue).join(',');
}

String _escapeCsvValue(dynamic value) {
  if (value == null) return '';
  if (value is num || value is bool) return value.toString();
  final stringValue = value.toString();
  final needsEscaping =
      stringValue.contains(',') ||
      stringValue.contains('"') ||
      stringValue.contains('\n') ||
      stringValue.contains('\r');

  if (!needsEscaping) return stringValue;

  final escaped = stringValue.replaceAll('"', '""');
  return '"$escaped"';
}
