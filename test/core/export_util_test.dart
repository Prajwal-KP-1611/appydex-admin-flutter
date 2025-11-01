import 'package:flutter_test/flutter_test.dart';

import 'package:appydex_admin/core/export_util.dart';

void main() {
  test('toCsv builds header from columns parameter', () {
    final csv = toCsv(
      [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ],
      columns: ['id', 'name'],
    );

    expect(csv.trim(), 'id,name\n1,Alice\n2,Bob');
  });

  test('toCsv escapes commas, quotes and new lines', () {
    final csv = toCsv(
      [
        {'id': 1, 'notes': 'Line1, with comma'},
        {'id': 2, 'notes': 'Multi\nline "quote"'},
      ],
      columns: ['id', 'notes'],
    );

    expect(
      csv.trim(),
      'id,notes\n1,"Line1, with comma"\n2,"Multi\nline ""quote"""',
    );
  });

  test('toCsv infers columns when not provided', () {
    final csv = toCsv([
      {'id': 1, 'name': 'Alice'},
    ]);

    expect(csv.startsWith('id,'), isTrue);
    expect(csv.contains('Alice'), isTrue);
  });
}
