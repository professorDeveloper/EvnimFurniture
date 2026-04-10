import 'package:flutter/material.dart';

class FurnitureDetailColor {
  const FurnitureDetailColor({
    required this.furnitureMaterialColorId,
    required this.colorId,
    required this.name,
    required this.hexCode,
    this.isDefault = false,
    this.comboImages = const [],
  });

  final String furnitureMaterialColorId;
  final String colorId;
  final String name;
  final String hexCode;
  final bool isDefault;
  final List<String> comboImages;

  Color get color {
    try {
      final hex = hexCode.replaceFirst('#', '').toUpperCase();
      if (hex.length != 6) return Colors.grey;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  factory FurnitureDetailColor.fromJson(Map<String, dynamic> json) {
    return FurnitureDetailColor(
      furnitureMaterialColorId:
          json['furnitureMaterialColorId'] as String? ?? '',
      colorId: json['colorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      comboImages: (json['comboImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class FurnitureDetailMaterialInfo {
  const FurnitureDetailMaterialInfo({
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

  factory FurnitureDetailMaterialInfo.fromJson(Map<String, dynamic> json) {
    return FurnitureDetailMaterialInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      ownImages: (json['ownImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FurnitureDetailMaterial {
  const FurnitureDetailMaterial({
    required this.furnitureMaterialId,
    this.modelFile,
    required this.material,
    this.colors = const [],
    this.colorCount = 0,
    this.defaultColor,
    this.isFavorited = false,
  });

  final String furnitureMaterialId;
  final String? modelFile;
  final FurnitureDetailMaterialInfo material;
  final List<FurnitureDetailColor> colors;
  final int colorCount;
  final FurnitureDetailColor? defaultColor;
  final bool isFavorited;

  factory FurnitureDetailMaterial.fromJson(Map<String, dynamic> json) {
    return FurnitureDetailMaterial(
      furnitureMaterialId: json['furnitureMaterialId'] as String? ?? '',
      modelFile: json['modelFile'] as String?,
      material: FurnitureDetailMaterialInfo.fromJson(
          json['material'] as Map<String, dynamic>),
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) =>
                  FurnitureDetailColor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      colorCount: (json['colorCount'] as num?)?.toInt() ?? 0,
      defaultColor: json['defaultColor'] != null
          ? FurnitureDetailColor.fromJson(
              json['defaultColor'] as Map<String, dynamic>)
          : null,
      isFavorited: json['isFavorited'] as bool? ?? false,
    );
  }
}

class FurnitureDetailStats {
  const FurnitureDetailStats({
    this.viewCount = 0,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.materialCount = 0,
    this.colorCount = 0,
  });

  final int viewCount;
  final double avgRating;
  final int ratingCount;
  final int materialCount;
  final int colorCount;

  factory FurnitureDetailStats.fromJson(Map<String, dynamic> json) {
    return FurnitureDetailStats(
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      materialCount: (json['materialCount'] as num?)?.toInt() ?? 0,
      colorCount: (json['colorCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class FurnitureDetailCategory {
  const FurnitureDetailCategory({
    required this.id,
    required this.name,
    this.slug,
  });

  final String id;
  final String name;
  final String? slug;

  factory FurnitureDetailCategory.fromJson(Map<String, dynamic> json) {
    return FurnitureDetailCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }
}

class FurnitureDetailResponse {
  const FurnitureDetailResponse({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailImage,
    this.images = const [],
    this.tags = const [],
    this.stats = const FurnitureDetailStats(),
    this.materials = const [],
    this.category,
  });

  final String id;
  final String name;
  final String? description;
  final String? thumbnailImage;
  final List<String> images;
  final List<String> tags;
  final FurnitureDetailStats stats;
  final List<FurnitureDetailMaterial> materials;
  final FurnitureDetailCategory? category;

  factory FurnitureDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return FurnitureDetailResponse(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      thumbnailImage: data['thumbnailImage'] as String?,
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (data['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stats: data['stats'] != null
          ? FurnitureDetailStats.fromJson(
              data['stats'] as Map<String, dynamic>)
          : const FurnitureDetailStats(),
      materials: (data['materials'] as List<dynamic>?)
              ?.map((e) => FurnitureDetailMaterial.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      category: data['category'] != null
          ? FurnitureDetailCategory.fromJson(
              data['category'] as Map<String, dynamic>)
          : null,
    );
  }
}
