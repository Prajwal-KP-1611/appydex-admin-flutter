/// Paginated API response wrapper
/// Matches the backend pagination format for admin endpoints
library;

/// Pagination metadata
class PaginationMeta {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }
}

/// Generic paginated response wrapper
///
/// Matches backend format:
/// ```json
/// {
///   "items": [...],
///   "meta": {
///     "page": 1,
///     "page_size": 25,
///     "total_items": 100,
///     "total_pages": 4,
///     "has_next": true,
///     "has_prev": false
///   }
/// }
/// ```
class PaginatedResponse<T> {
  /// List of deserialized items
  final List<T> data;

  /// Pagination metadata
  final PaginationMeta meta;

  PaginatedResponse({required this.data, required this.meta});

  /// Factory that is tolerant of backend variations:
  /// Supports either `{ items: [...], meta: {...} }` OR `{ data: [...], meta: {...} }`.
  /// This keeps forward compatibility if backend standardized on `data`.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Prefer `items`, fallback to `data`.
    final rawList = (json['items'] ?? json['data']) as List<dynamic>? ?? [];
    final data = rawList
        .whereType<Map<String, dynamic>>()
        .map(fromJsonT)
        .toList();

    final metaJson = json['meta'];
    if (metaJson is! Map<String, dynamic>) {
      throw StateError(
        'PaginatedResponse requires a meta object with pagination fields. Received: ${metaJson.runtimeType}',
      );
    }
    final meta = PaginationMeta.fromJson(metaJson);
    return PaginatedResponse<T>(data: data, meta: meta);
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': data.map((item) => toJsonT(item)).toList(),
      'meta': meta.toJson(),
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => meta.hasNext;

  /// Check if there are previous pages
  bool get hasPrevPage => meta.hasPrev;

  /// Get next page number (or null if no next page)
  int? get nextPage => hasNextPage ? meta.page + 1 : null;

  /// Get previous page number (or null if no previous page)
  int? get prevPage => hasPrevPage ? meta.page - 1 : null;

  /// Check if this is the first page
  bool get isFirstPage => meta.page == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasNextPage;
}
