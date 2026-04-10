import '../../domain/model/material_item.dart';

class MaterialFurnitureResponse {
  const MaterialFurnitureResponse({
    required this.material,
    required this.furniture,
  });

  final MaterialSummary material;
  final List<MaterialFurnitureItem> furniture;

  factory MaterialFurnitureResponse.fromJson(Map<String, dynamic> json) {
    final dynamic raw = json['data'] ?? json;
    final Map<String, dynamic> data = raw is Map<String, dynamic> ? raw : json;

    return MaterialFurnitureResponse(
      material: MaterialSummary.fromJson(
          data['material'] as Map<String, dynamic>? ?? {}),
      furniture: (data['furniture'] as List<dynamic>?)
              ?.map((e) =>
                  MaterialFurnitureItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MaterialSummary {
  const MaterialSummary({
    required this.id,
    required this.name,
    this.description,
    this.ownImages = const [],
    this.viewCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final List<String> ownImages;
  final int viewCount;

  String? get firstImage => ownImages.isNotEmpty ? ownImages.first : null;

  @override
  String toString() =>
      'MaterialSummary(id: $id, name: $name, description: $description, ownImages: $ownImages, viewCount: $viewCount)';

  factory MaterialSummary.fromJson(Map<String, dynamic> json) {
    return MaterialSummary(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      ownImages: (json['ownImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e != 'string' && e.isNotEmpty)
              .toList() ??
          [],
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MaterialFurnitureItem {
  const MaterialFurnitureItem({
    required this.furnitureMaterialId,
    this.modelFile,
    this.isFavorited = false,
    this.defaultColor,
    required this.furniture,
  });

  final String furnitureMaterialId;
  final String? modelFile;
  final bool isFavorited;
  final MaterialDefaultColor? defaultColor;
  final MaterialFurnitureInfo furniture;

  @override
  String toString() =>
      'MaterialFurnitureItem(furnitureMaterialId: $furnitureMaterialId, modelFile: $modelFile, isFavorited: $isFavorited, defaultColor: $defaultColor, furniture: $furniture)';

  factory MaterialFurnitureItem.fromJson(Map<String, dynamic> json) {
    return MaterialFurnitureItem(
      furnitureMaterialId: json['furnitureMaterialId'] as String? ?? '',
      modelFile: json['modelFile'] as String?,
      isFavorited: json['isFavorited'] as bool? ?? false,
      defaultColor: json['defaultColor'] != null
          ? MaterialDefaultColor.fromJson(
              json['defaultColor'] as Map<String, dynamic>)
          : null,
      furniture: MaterialFurnitureInfo.fromJson(
          json['furniture'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MaterialFurnitureInfo {
  const MaterialFurnitureInfo({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailImage,
    this.avgRating = 0.0,
    this.viewCount = 0,
    this.ratingCount = 0,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? thumbnailImage;
  final double avgRating;
  final int viewCount;
  final int ratingCount;
  final List<String> tags;

  factory MaterialFurnitureInfo.fromJson(Map<String, dynamic> json) {
    return MaterialFurnitureInfo(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailImage: json['thumbnailImage'] as String?,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e != 'string' && e.isNotEmpty)
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'MaterialFurnitureInfo(id: $id, name: $name, description: $description, thumbnailImage: $thumbnailImage, avgRating: $avgRating, viewCount: $viewCount, ratingCount: $ratingCount, tags: $tags)';
}
