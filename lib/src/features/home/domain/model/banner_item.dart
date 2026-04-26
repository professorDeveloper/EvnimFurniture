class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    this.furnitureMaterialId,
    this.furnitureCombinationId,
    required this.order,
  });

  final String id;
  final String imageUrl;
  final String? furnitureMaterialId;
  final String? furnitureCombinationId;
  final int order;

  bool get hasLink =>
      (furnitureMaterialId != null && furnitureMaterialId!.isNotEmpty) ||
      (furnitureCombinationId != null && furnitureCombinationId!.isNotEmpty);
}