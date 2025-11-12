/// Unit tests for PaginatedResponse
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:appydex_admin/core/paginated_response.dart';

void main() {
  group('PaginatedResponse', () {
    group('fromJson with items key', () {
      test('should parse response with items key correctly', () {
        final json = {
          'items': [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
          ],
          'meta': {'page': 1, 'pageSize': 10, 'totalItems': 2, 'totalPages': 1},
        };

        final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );

        expect(response.data.length, 2);
        expect(response.data[0]['id'], 1);
        expect(response.data[1]['id'], 2);
        expect(response.meta.page, 1);
        expect(response.meta.totalItems, 2);
      });
    });

    group('fromJson with data key', () {
      test('should parse response with data key correctly', () {
        final json = {
          'data': [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
          ],
          'meta': {'page': 1, 'pageSize': 10, 'totalItems': 2, 'totalPages': 1},
        };

        final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );

        expect(response.data.length, 2);
        expect(response.data[0]['id'], 1);
        expect(response.data[1]['id'], 2);
        expect(response.meta.page, 1);
        expect(response.meta.totalItems, 2);
      });
    });

    group('fromJson with empty items', () {
      test('should handle empty items array', () {
        final json = {
          'items': [],
          'meta': {'page': 1, 'pageSize': 10, 'totalItems': 0, 'totalPages': 0},
        };

        final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );

        expect(response.data, isEmpty);
        expect(response.meta.totalItems, 0);
      });
    });

    group('fromJson with missing meta', () {
      test('should throw error when meta is missing', () {
        final json = {
          'items': [
            {'id': 1, 'name': 'Item 1'},
          ],
        };

        expect(
          () => PaginatedResponse<Map<String, dynamic>>.fromJson(
            json,
            (item) => item,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('fromJson with neither items nor data', () {
      test('should throw error when neither items nor data exists', () {
        final json = {
          'results': [
            {'id': 1, 'name': 'Item 1'},
          ],
          'meta': {'page': 1, 'pageSize': 10, 'totalItems': 1, 'totalPages': 1},
        };

        expect(
          () => PaginatedResponse<Map<String, dynamic>>.fromJson(
            json,
            (item) => item,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Pagination helpers', () {
      late PaginatedResponse<Map<String, dynamic>> response;

      setUp(() {
        final json = {
          'items': [
            {'id': 1},
            {'id': 2},
          ],
          'meta': {
            'page': 2,
            'pageSize': 10,
            'totalItems': 25,
            'totalPages': 3,
          },
        };

        response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );
      });

      test('hasNextPage should return true when not on last page', () {
        expect(response.hasNextPage, true);
      });

      test('hasPrevPage should return true when not on first page', () {
        expect(response.hasPrevPage, true);
      });

      test('nextPage should return correct next page number', () {
        expect(response.nextPage, 3);
      });

      test('prevPage should return correct previous page number', () {
        expect(response.prevPage, 1);
      });
    });

    group('Pagination edge cases', () {
      test('hasNextPage should return false on last page', () {
        final json = {
          'items': [
            {'id': 1},
          ],
          'meta': {
            'page': 3,
            'pageSize': 10,
            'totalItems': 25,
            'totalPages': 3,
          },
        };

        final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );

        expect(response.hasNextPage, false);
      });

      test('hasPrevPage should return false on first page', () {
        final json = {
          'items': [
            {'id': 1},
          ],
          'meta': {
            'page': 1,
            'pageSize': 10,
            'totalItems': 25,
            'totalPages': 3,
          },
        };

        final response = PaginatedResponse<Map<String, dynamic>>.fromJson(
          json,
          (item) => item,
        );

        expect(response.hasPrevPage, false);
      });
    });
  });
}
