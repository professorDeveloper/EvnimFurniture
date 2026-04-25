import '../../../home/domain/model/furniture_item.dart';
import '../model/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryItem>> getCategories();
  Future<List<FurnitureItem>> getCategoryFurniture({required String slug});
}
