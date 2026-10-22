class SSFeedItem {
  const SSFeedItem({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.userId,
  });

  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final int? userId;

  factory SSFeedItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return SSFeedItem(
      id: id,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int?,
      imageUrl: json['imageUrl'] as String? ??
          'https://picsum.photos/seed/ssfeed$id/800/450',
    );
  }
}
