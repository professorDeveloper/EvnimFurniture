
import 'material_item.dart';

class MaterialListResponseDto {
  const MaterialListResponseDto({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<MaterialListItemDto> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  factory MaterialListResponseDto.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    return MaterialListResponseDto(
      items: data
          .map((e) => MaterialListItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int,
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }

  MaterialListResponse toDomain() => MaterialListResponse(
        items: items.map((e) => e.toDomain()).toList(),
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
      );
}

class MaterialListItemDto {
  const MaterialListItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.ownImages,
    required this.furnitureCount,
    required this.viewCount,
    required this.createdAt,
    this.defaultColor,
  });

  final String id;
  final String name;
  final String description;
  final String previewImage;
  final List<String> ownImages;
  final int furnitureCount;
  final int viewCount;
  final DateTime createdAt;
  final MaterialDefaultColorDto? defaultColor;

  factory MaterialListItemDto.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return MaterialListItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      previewImage: json['previewImage'] as String? ?? '',
      ownImages: (json['ownImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      furnitureCount: stats['furnitureCount'] as int? ?? 0,
      viewCount: stats['viewCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      defaultColor: json['defaultColor'] != null
          ? MaterialDefaultColorDto.fromJson(
              json['defaultColor'] as Map<String, dynamic>)
          : null,
    );
  }

  MaterialListItem toDomain() => MaterialListItem(
        id: id,
        name: name,
        description: description,
        previewImage: previewImage,
        ownImages: ownImages,
        furnitureCount: furnitureCount,
        viewCount: viewCount,
        createdAt: createdAt,
        defaultColor: defaultColor?.toDomain(),
      );
}

class MaterialDefaultColorDto {
  const MaterialDefaultColorDto({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.previewImage,
  });

  final String id;
  final String name;
  final String hexCode;
  final String previewImage;

  factory MaterialDefaultColorDto.fromJson(Map<String, dynamic> json) =>
      MaterialDefaultColorDto(
        id: json['id'] as String,
        name: json['name'] as String,
        hexCode: json['hexCode'] as String,
        previewImage: json['previewImage'] as String? ?? '',
      );

  MaterialDefaultColor toDomain() => MaterialDefaultColor(
        id: id,
        name: name,
        hexCode: hexCode,
        previewImage: previewImage,
      );
}
