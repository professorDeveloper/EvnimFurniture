class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.image,
    this.type = 'general',
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? body;
  final String? image;
  final String type;
  final DateTime createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      image: json['image'] as String?,
      type: json['type'] as String? ?? 'general',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.page,
    required this.total,
    required this.pages,
  });

  final List<NotificationItem> items;
  final int page;
  final int total;
  final int pages;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return NotificationPage(
      items: ((json['data'] as List?) ?? [])
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? 1,
      total: pagination['total'] as int? ?? 0,
      pages: pagination['pages'] as int? ?? 1,
    );
  }
}
