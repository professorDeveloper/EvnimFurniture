import 'package:flutter/material.dart';

class MaterialDefaultColor {
  const MaterialDefaultColor({
    required this.id,
    required this.name,
    required this.hexCode,
    this.previewImage,
  });

  final String id;
  final String name;
  final String hexCode;
  final String? previewImage;

  Color get color {
    if (hexCode.isEmpty) return Colors.grey;
    try {
      final String hex = hexCode.replaceFirst('#', '').toUpperCase();
      if (hex.length != 6) return Colors.grey;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  String toString() =>
      'MaterialDefaultColor(id: $id, name: $name, hexCode: $hexCode, previewImage: $previewImage, color: $color)';

  factory MaterialDefaultColor.fromJson(Map<String, dynamic> json) {
    return MaterialDefaultColor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hexCode: json['hexCode'] as String? ?? '#CCCCCC',
      previewImage: json['previewImage'] as String?,
    );
  }
}

class MaterialStats {
  const MaterialStats({
    this.viewCount = 0,
    this.furnitureCount = 0,
  });

  final int viewCount;
  final int furnitureCount;

  factory MaterialStats.fromJson(Map<String, dynamic> json) {
    return MaterialStats(
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      furnitureCount: (json['furnitureCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() =>
      'MaterialStats(viewCount: $viewCount, furnitureCount: $furnitureCount)';
}

class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.name,
    this.rank,
    this.description,
    this.previewImage,
    this.ownImages = const [],
    this.defaultColor,
    this.stats = const MaterialStats(),
  });

  final String id;
  final String name;
  final int? rank;
  final String? description;
  final String? previewImage;
  final List<String> ownImages;
  final MaterialDefaultColor? defaultColor;
  final MaterialStats stats;

  String? get firstImage =>
      previewImage ?? (ownImages.isNotEmpty ? ownImages.first : null);

  @override
  String toString() =>
      'MaterialItem(id: $id, name: $name, rank: $rank, description: $description, previewImage: $previewImage, ownImages: $ownImages, defaultColor: $defaultColor, stats: $stats)';

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rank: json['rank'] as int?,
      description: json['description'] as String?,
      previewImage: json['previewImage'] as String?,
      ownImages: (json['ownImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e != 'string' && e.isNotEmpty)
              .toList() ??
          [],
      defaultColor: json['defaultColor'] != null
          ? MaterialDefaultColor.fromJson(
              json['defaultColor'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? MaterialStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const MaterialStats(),
    );
  }
}
