import 'category_model.dart';
import 'combination_item.dart';
import 'furniture_item.dart';
import 'material_item.dart';
import 'story_item.dart';

import 'banner_item.dart';

class HomeData {
  const HomeData({
    required this.stories,
    required this.banners,
    required this.categories,
    required this.topFurniture,
    required this.topMaterials,
    required this.topCombinations,
  });

  final List<StoryItem> stories;
  final List<BannerItem> banners;
  final List<CategoryItem> categories;
  final List<FurnitureItem> topFurniture;
  final List<MaterialItem> topMaterials;
  final List<CombinationItem> topCombinations;
}
