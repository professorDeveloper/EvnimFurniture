import 'material_item.dart';

class FurnitureStats {
  const FurnitureStats({
    this.viewCount = 0,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.materialCount = 0,
  });

  final int viewCount;
  final double avgRating;
  final int ratingCount;
  final int materialCount;

  factory FurnitureStats.fromJson(Map<String, dynamic> json) {
    return FurnitureStats(
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      materialCount: (json['materialCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FurnitureItem {
  const FurnitureItem({
    required this.id,
    required this.name,
    this.rank,
    this.description,
    this.thumbnailImage,
    this.stats = const FurnitureStats(),
    this.tags = const [],
    this.defaultColor,
    this.defaultMaterialId,
    this.isFavorited = false,
    this.colors = const [],
  });

  final String id;
  final String name;
  final int? rank;
  final String? description;
  final String? thumbnailImage;
  final FurnitureStats stats;
  final List<String> tags;
  final MaterialDefaultColor? defaultColor;
  final String? defaultMaterialId;
  final bool isFavorited;

  final List<MaterialDefaultColor> colors;

  factory FurnitureItem.fromJson(Map<String, dynamic> json) {
    final defaultColor = json['defaultColor'] != null
        ? MaterialDefaultColor.fromJson(
            json['defaultColor'] as Map<String, dynamic>)
        : null;

    final colorsList = (json['colors'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MaterialDefaultColor.fromJson)
            .toList() ??
        [];

    final List<MaterialDefaultColor> resolvedColors = colorsList.isNotEmpty
        ? colorsList
        : (defaultColor != null
            ? <MaterialDefaultColor>[defaultColor]
            : <MaterialDefaultColor>[]);

    return FurnitureItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rank: json['rank'] as int?,
      description: json['description'] as String?,
      thumbnailImage: json['thumbnailImage'] as String?,
      stats: json['stats'] != null
          ? FurnitureStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const FurnitureStats(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      defaultColor: defaultColor,
      defaultMaterialId: json['defaultMaterialId'] as String?,
      isFavorited: json['isFavorited'] as bool? ?? false,
      colors: resolvedColors,
    );
  }
}
