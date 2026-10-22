/// Cursor-based pagination result.
class SSCursorPage<T> {
  const SSCursorPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  factory SSCursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) itemParser, {
    String itemsKey = 'items',
    String nextCursorKey = 'nextCursor',
    String hasMoreKey = 'hasMore',
  }) {
    final rawItems = json[itemsKey] as List<dynamic>? ?? [];
    return SSCursorPage(
      items: rawItems
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json[nextCursorKey] as String?,
      hasMore: json[hasMoreKey] as bool? ??
          (json[nextCursorKey] != null && (json[nextCursorKey] as String).isNotEmpty),
    );
  }
}
