class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    this.slug = '',
    this.coverImage,
    this.furnitureCount = 0,
    this.icon,
  });

  final String id;
  final String name;
  final String slug;
  final String? coverImage;
  final int furnitureCount;
  final String? icon;

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      furnitureCount: (json['furnitureCount'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
    );
  }
}
