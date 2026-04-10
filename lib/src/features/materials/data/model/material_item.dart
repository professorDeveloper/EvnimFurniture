import 'package:flutter/material.dart';

class MaterialListItem {
  const MaterialListItem({
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
  final MaterialDefaultColor? defaultColor;

  @override
  String toString() =>
      'MaterialListItem(id: $id, name: $name, description: $description, previewImage: $previewImage, ownImages: $ownImages, furnitureCount: $furnitureCount, viewCount: $viewCount, createdAt: $createdAt, defaultColor: $defaultColor)';
}

class MaterialDefaultColor {
  const MaterialDefaultColor({
    required this.id,
    required this.name,
    required this.hexCode,
    required this.previewImage,
  });

  final String id;
  final String name;
  final String hexCode;
  final String previewImage;

  Color get color {
    try {
      final hex = hexCode.replaceFirst('#', '').toUpperCase();
      if (hex.length != 6) return Colors.grey;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  String toString() =>
      'MaterialDefaultColor(id: $id, name: $name, hexCode: $hexCode, previewImage: $previewImage, color: $color)';
}

class MaterialListResponse {
  const MaterialListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<MaterialListItem> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}
