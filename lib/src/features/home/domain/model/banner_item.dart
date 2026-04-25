class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    this.furnitureMaterialId,
    required this.order,
  });

  final String id;
  final String imageUrl;
  final String? furnitureMaterialId;
  final int order;
}