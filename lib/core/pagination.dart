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
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(decode)
        .toList();

    return Pagination<T>(
      items: items,
      total: json['total'] as int? ?? items.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? items.length,
    );
  }
}
