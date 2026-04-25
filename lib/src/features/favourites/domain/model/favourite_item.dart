class FavouriteItem {
  const FavouriteItem({
    required this.id,
    required this.furnitureId,
    required this.furnitureMaterialId,
    required this.furnitureName,
    this.thumbnailImage,
    required this.materialName,
    required this.createdAt,
  });

  final String id;
  final String furnitureId;
  final String furnitureMaterialId;
  final String furnitureName;
  final String? thumbnailImage;
  final String materialName;
  final DateTime createdAt;

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    final fm = json['furnitureMaterialId'] as Map<String, dynamic>? ?? {};
    final furniture = fm['furnitureModelId'] as Map<String, dynamic>? ?? {};
    final material = fm['materialId'] as Map<String, dynamic>? ?? {};

    return FavouriteItem(
      id: json['_id'] as String? ?? '',
      furnitureId: furniture['_id'] as String? ?? '',
      furnitureMaterialId: fm['_id'] as String? ?? '',
      furnitureName: furniture['name'] as String? ?? '',
      thumbnailImage: furniture['thumbnailImage'] as String?,
      materialName: material['name'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
