import '../../data/model/furniture_detail_response.dart';
import '../../data/model/furniture_material_colors_response.dart';
import '../../data/model/material_furniture_response.dart';
import '../model/banner_item.dart';
import '../model/category_model.dart';
import '../model/combination_item.dart';
import '../model/furniture_item.dart';
import '../model/material_item.dart';
import '../model/story_item.dart';

abstract class HomeRepository {
  Future<List<BannerItem>> getBanners();
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10});
  Future<List<MaterialItem>> getTopMaterials({int limit = 10});
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20});
  Future<List<CategoryItem>> getCategories();
  Future<List<CombinationItem>> getTopCombinations({int limit = 10});
  Future<List<CombinationItem>> getTopCombinationsPaged({int page = 1, int limit = 10});

  Future<MaterialFurnitureResponse> getMaterialFurniture({
    required String materialId,
    int page = 1,
    int limit = 20,
  });

  Future<FurnitureDetailResponse> getFurnitureDetail({
    required String furnitureId,
  });

  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  });
}