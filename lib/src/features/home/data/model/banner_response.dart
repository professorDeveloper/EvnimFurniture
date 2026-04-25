class BannerResponse {
  const BannerResponse({
    required this.id,
    required this.image,
    this.furnitureMaterialId,
    required this.order,
  });

  final String id;
  final String image;
  final String? furnitureMaterialId;
  final int order;

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      id: json['_id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      furnitureMaterialId: json['furnitureMaterialId'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'furnitureMaterialId': furnitureMaterialId,
      'order': order,
    };
  }
}
