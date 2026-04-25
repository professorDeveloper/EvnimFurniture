import '../../../home/domain/model/furniture_item.dart';
import '../repositories/category_repository.dart';

class GetCategoryFurnitureUseCase {
  const GetCategoryFurnitureUseCase({required this.repository});

  final CategoryRepository repository;

  Future<List<FurnitureItem>> call({required String slug}) =>
      repository.getCategoryFurniture(slug: slug);
}
