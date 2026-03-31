class StoryItem {
  const StoryItem({
    required this.id,
    required this.title,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.thumbnailUrl,
    this.duration = 15,
    this.viewsCount = 0,
    this.furnitureMaterialId,
    this.isSeen = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String mediaUrl;
  final String mediaType;
  final String? thumbnailUrl;
  final int duration;
  final int viewsCount;
  final String? furnitureMaterialId;
  final bool isSeen;
  final DateTime? createdAt;

  String get displayImage => thumbnailUrl ?? mediaUrl;

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'] as String);
      } catch (_) {}
    }
    return StoryItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String? ?? 'image',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: (json['duration'] as num?)?.toInt() ?? 15,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      furnitureMaterialId: json['furnitureMaterialId'] as String?,
      createdAt: createdAt,
    );
  }
}
