import '../model/category_model.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase({required this.repository});

  final CategoryRepository repository;

  Future<List<CategoryItem>> call() => repository.getCategories();
}
