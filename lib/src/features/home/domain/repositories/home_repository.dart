import '../model/category_model.dart';
import '../model/combination_item.dart';
import '../model/furniture_item.dart';
import '../model/material_item.dart';
import '../model/story_item.dart';

abstract class HomeRepository {
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10});
  Future<List<MaterialItem>> getTopMaterials({int limit = 10});
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20});
  Future<List<CategoryItem>> getCategories();
  Future<List<CombinationItem>> getTopCombinations({int limit = 10});
}
