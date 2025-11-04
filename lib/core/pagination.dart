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
    // Support both old format {items, total, page, page_size}
    // and new format {data, meta: {page, page_size, total, total_pages}}
    List<dynamic> itemsList;
    int total;
    int page;
    int pageSize;

    if (json.containsKey('data') && json.containsKey('meta')) {
      // New format: {data: [...], meta: {...}}
      itemsList = json['data'] as List<dynamic>? ?? const [];
      final meta = json['meta'] as Map<String, dynamic>? ?? {};
      total = meta['total'] as int? ?? itemsList.length;
      page = meta['page'] as int? ?? 1;
      pageSize = meta['page_size'] as int? ?? itemsList.length;
    } else {
      // Old format: {items: [...], total, page, page_size}
      itemsList = json['items'] as List<dynamic>? ?? const [];
      total = json['total'] as int? ?? itemsList.length;
      page = json['page'] as int? ?? 1;
      pageSize = json['page_size'] as int? ?? itemsList.length;
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
