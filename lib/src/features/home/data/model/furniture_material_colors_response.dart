import 'package:flutter/material.dart';

class FurnitureMaterialColor {
  const FurnitureMaterialColor({
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

  String? get firstComboImage =>
      comboImages.isNotEmpty ? comboImages.first : null;

  factory FurnitureMaterialColor.fromJson(Map<String, dynamic> json) {
    return FurnitureMaterialColor(
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

// ─────────────────────────────────────────────────────────────────────────────
// Material info
// ─────────────────────────────────────────────────────────────────────────────

class FurnitureMaterialColorsMaterial {
  const FurnitureMaterialColorsMaterial({
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

  bool get isEmpty => id.isEmpty && name.isEmpty;
  String? get firstImage => ownImages.isNotEmpty ? ownImages.first : null;

  factory FurnitureMaterialColorsMaterial.fromJson(Map<String, dynamic> json) {
    return FurnitureMaterialColorsMaterial(
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


class FMCStats {
  const FMCStats({
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.viewCount = 0,
  });

  final double avgRating;
  final int ratingCount;
  final int viewCount;

  factory FMCStats.fromJson(Map<String, dynamic> json) {
    return FMCStats(
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }
}


class FMCFurniture {
  const FMCFurniture({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailImage,
    this.images = const [],
    this.tags = const [],
    this.stats = const FMCStats(),
  });

  final String id;
  final String name;
  final String? description;
  final String? thumbnailImage;
  final List<String> images;
  final List<String> tags;
  final FMCStats stats;

  /// thumbnail + images combined (for PageView)
  List<String> get allImages {
    final result = <String>[];
    if (thumbnailImage != null && thumbnailImage!.isNotEmpty) {
      result.add(thumbnailImage!);
    }
    result.addAll(images.where((e) => e.isNotEmpty));
    return result;
  }

  factory FMCFurniture.fromJson(Map<String, dynamic> json) {
    return FMCFurniture(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailImage: json['thumbnailImage'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      stats: json['stats'] != null
          ? FMCStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const FMCStats(),
    );
  }
}


class FMCOtherMaterial {
  const FMCOtherMaterial({
    required this.furnitureMaterialId,
    this.modelFile,
    required this.materialName,
    this.previewImage,
  });

  final String furnitureMaterialId;
  final String? modelFile;
  final String materialName;
  final String? previewImage;

  factory FMCOtherMaterial.fromJson(Map<String, dynamic> json) {
    final mat = json['material'] as Map<String, dynamic>? ?? {};
    return FMCOtherMaterial(
      furnitureMaterialId: json['furnitureMaterialId'] as String? ?? '',
      modelFile: json['modelFile'] as String?,
      materialName: mat['name'] as String? ?? '',
      previewImage: mat['previewImage'] as String?,
    );
  }
}


class FurnitureMaterialColorsResponse {
  const FurnitureMaterialColorsResponse({
    required this.furnitureMaterialId,
    this.modelFile,
    required this.furniture,
    required this.material,
    this.colors = const [],
    this.defaultColor,
    this.colorCount = 0,
    this.isFavorited = false,
    this.myRating,
    this.otherMaterials = const [],
  });

  final String furnitureMaterialId;
  final String? modelFile;
  final FMCFurniture furniture;
  final FurnitureMaterialColorsMaterial material;
  final List<FurnitureMaterialColor> colors;
  final FurnitureMaterialColor? defaultColor;
  final int colorCount;
  final bool isFavorited;
  final int? myRating;
  final List<FMCOtherMaterial> otherMaterials;

  bool get has3dModel => modelFile != null && modelFile!.isNotEmpty;

  FurnitureMaterialColorsResponse copyWithStats({
    double? avgRating,
    int? ratingCount,
  }) {
    return FurnitureMaterialColorsResponse(
      furnitureMaterialId: furnitureMaterialId,
      modelFile: modelFile,
      furniture: FMCFurniture(
        id: furniture.id,
        name: furniture.name,
        description: furniture.description,
        thumbnailImage: furniture.thumbnailImage,
        images: furniture.images,
        tags: furniture.tags,
        stats: FMCStats(
          avgRating: avgRating ?? furniture.stats.avgRating,
          ratingCount: ratingCount ?? furniture.stats.ratingCount,
          viewCount: furniture.stats.viewCount,
        ),
      ),
      material: material,
      colors: colors,
      defaultColor: defaultColor,
      colorCount: colorCount,
      isFavorited: isFavorited,
      myRating: myRating,
      otherMaterials: otherMaterials,
    );
  }

  factory FurnitureMaterialColorsResponse.fromJson(
      Map<String, dynamic> json) {
    final raw = (json['data'] as Map<String, dynamic>?) ?? json;

    // furnitureMaterial block
    final fmBlock =
        raw['furnitureMaterial'] as Map<String, dynamic>? ?? {};
    final furnitureMaterialId =
        (fmBlock['id'] ?? raw['id'] ?? raw['furnitureMaterialId'])
                ?.toString() ??
            '';
    final modelFile = (fmBlock['modelFile'] ??
        fmBlock['3dModelFile'] ??
        raw['modelFile'] ??
        raw['3dModelFile']) as String?;

    // furniture
    final furnitureJson =
        raw['furniture'] as Map<String, dynamic>? ?? {};

    // material
    final materialJson =
        raw['material'] as Map<String, dynamic>? ?? {};

    // colors
    final colorsJson =
        (raw['colors'] as List<dynamic>?) ?? [];

    // defaultColor (may be empty map {})
    FurnitureMaterialColor? defaultColor;
    final dcJson = raw['defaultColor'];
    if (dcJson is Map<String, dynamic> && dcJson.isNotEmpty) {
      try {
        defaultColor = FurnitureMaterialColor.fromJson(dcJson);
      } catch (_) {}
    }

    // user
    final userJson = raw['user'] as Map<String, dynamic>? ?? {};

    // otherMaterials
    final otherJson =
        (raw['otherMaterials'] as List<dynamic>?) ?? [];

    return FurnitureMaterialColorsResponse(
      furnitureMaterialId: furnitureMaterialId,
      modelFile: modelFile?.isNotEmpty == true ? modelFile : null,
      furniture: FMCFurniture.fromJson(furnitureJson),
      material:
          FurnitureMaterialColorsMaterial.fromJson(materialJson),
      colors: colorsJson
          .whereType<Map<String, dynamic>>()
          .map(FurnitureMaterialColor.fromJson)
          .toList(),
      defaultColor: defaultColor,
      colorCount: (raw['colorCount'] as num?)?.toInt() ?? 0,
      isFavorited: (userJson['isFavorited'] as bool?) ?? false,
      myRating: (userJson['myRating'] as num?)?.toInt(),
      otherMaterials: otherJson
          .whereType<Map<String, dynamic>>()
          .map(FMCOtherMaterial.fromJson)
          .toList(),
    );
  }
}
