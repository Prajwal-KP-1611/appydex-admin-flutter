class Pagination<T> {
  Pagination({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  int get totalPages => (total / pageSize).ceil().clamp(1, 1 << 31);

  Pagination<S> map<S>(S Function(T item) convert) {
    return Pagination<S>(
      items: items.map(convert).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  factory Pagination.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) decode,
  ) {
    // Support 3 backend pagination formats:
    // Format A: {items: [], total, skip, limit} - accounts, service-types
    // Format B: {items: [], meta: {page, page_size, total}} - vendors
    // Format C: {data: [], meta: {page, page_size, total}} - jobs
    List<dynamic> itemsList;
    int total;
    int page;
    int pageSize;

    if (json.containsKey('data') && json.containsKey('meta')) {
      // Format C: {data: [...], meta: {...}}
      itemsList = json['data'] as List<dynamic>? ?? const [];
      final meta = json['meta'] as Map<String, dynamic>? ?? {};
      total = meta['total'] as int? ?? itemsList.length;
      page = meta['page'] as int? ?? 1;
      pageSize = _resolvePageSize(meta, fallback: itemsList.length);
    } else if (json.containsKey('items') && json.containsKey('meta')) {
      // Format B: {items: [...], meta: {...}}
      itemsList = json['items'] as List<dynamic>? ?? const [];
      final meta = json['meta'] as Map<String, dynamic>? ?? {};
      total = meta['total'] as int? ?? itemsList.length;
      page = meta['page'] as int? ?? 1;
      pageSize = _resolvePageSize(meta, fallback: itemsList.length);
    } else {
      // Format A: {items: [...], total, skip, limit}
      itemsList = json['items'] as List<dynamic>? ?? const [];
      total = json['total'] as int? ?? itemsList.length;
      final skip = json['skip'] as int? ?? 0;
      final limit =
          json['limit'] as int? ??
          json['page_size'] as int? ??
          itemsList.length;
      pageSize = limit;
      // Calculate page from skip and limit
      page = limit > 0 ? (skip ~/ limit) + 1 : 1;
    }

    final items = itemsList
        .whereType<Map<String, dynamic>>()
        .map(decode)
        .toList();

    return Pagination<T>(
      items: items,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }
}

int _resolvePageSize(Map<String, dynamic> meta, {required int fallback}) {
  return meta['page_size'] as int? ?? meta['limit'] as int? ?? fallback;
}
