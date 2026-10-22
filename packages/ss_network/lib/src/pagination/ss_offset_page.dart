/// Offset / page-number pagination result.
class SSOffsetPage<T> {
  const SSOffsetPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.total,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int? total;

  factory SSOffsetPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) itemParser, {
    String itemsKey = 'items',
    String pageKey = 'page',
    String pageSizeKey = 'pageSize',
    String hasMoreKey = 'hasMore',
    String totalKey = 'total',
  }) {
    final rawItems = json[itemsKey] as List<dynamic>? ?? [];
    return SSOffsetPage(
      items: rawItems
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(),
      page: json[pageKey] as int? ?? 1,
      pageSize: json[pageSizeKey] as int? ?? rawItems.length,
      hasMore: json[hasMoreKey] as bool? ?? false,
      total: json[totalKey] as int?,
    );
  }
}
