class CombinationDefaultColor {
  const CombinationDefaultColor({
    required this.id,
    required this.name,
    required this.hexCode,
    this.comboImages = const [],
  });

  final String id;
  final String name;
  final String hexCode;
  final List<String> comboImages;

  factory CombinationDefaultColor.fromJson(Map<String, dynamic> json) {
    return CombinationDefaultColor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '#CCCCCC',
      comboImages: (json['comboImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty && e != 'string')
              .toList() ??
          [],
    );
  }
}

class CombinationFurniture {
  const CombinationFurniture({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailImage,
    this.viewCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final String? thumbnailImage;
  final int viewCount;

  factory CombinationFurniture.fromJson(Map<String, dynamic> json) {
    return CombinationFurniture(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailImage: json['thumbnailImage'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CombinationMaterial {
  const CombinationMaterial({
    required this.id,
    required this.name,
    this.description,
    this.previewImage,
  });

  final String id;
  final String name;
  final String? description;
  final String? previewImage;

  factory CombinationMaterial.fromJson(Map<String, dynamic> json) {
    return CombinationMaterial(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      previewImage: json['previewImage'] as String?,
    );
  }
}

class CombinationCategory {
  const CombinationCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;

  factory CombinationCategory.fromJson(Map<String, dynamic> json) {
    return CombinationCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class CombinationItem {
  const CombinationItem({
    required this.rank,
    required this.furnitureMaterialId,
    this.modelFile,
    this.favoriteCount = 0,
    this.isFavorited = false,
    this.defaultColor,
    required this.furniture,
    required this.material,
    required this.category,
  });

  final int rank;
  final String furnitureMaterialId;
  final String? modelFile;
  final int favoriteCount;
  final bool isFavorited;
  final CombinationDefaultColor? defaultColor;
  final CombinationFurniture furniture;
  final CombinationMaterial material;
  final CombinationCategory category;

  String? get displayImage => furniture.thumbnailImage;

  factory CombinationItem.fromJson(Map<String, dynamic> json) {
    return CombinationItem(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      furnitureMaterialId: json['furnitureMaterialId'] as String? ?? '',
      modelFile: json['modelFile'] as String?,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      isFavorited: json['isFavorited'] as bool? ?? false,
      defaultColor: json['defaultColor'] != null
          ? CombinationDefaultColor.fromJson(
              json['defaultColor'] as Map<String, dynamic>)
          : null,
      furniture: json['furniture'] != null
          ? CombinationFurniture.fromJson(
              json['furniture'] as Map<String, dynamic>)
          : CombinationFurniture(id: '', name: ''),
      material: json['material'] != null
          ? CombinationMaterial.fromJson(
              json['material'] as Map<String, dynamic>)
          : CombinationMaterial(id: '', name: ''),
      category: json['category'] != null
          ? CombinationCategory.fromJson(
              json['category'] as Map<String, dynamic>)
          : CombinationCategory(id: '', name: '', slug: ''),
    );
  }
}
