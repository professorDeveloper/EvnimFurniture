import '../../../home/domain/model/furniture_item.dart';
import '../../domain/model/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl({required this.remoteDataSource});

  final CategoryRemoteDataSource remoteDataSource;

  @override
  Future<List<CategoryItem>> getCategories() =>
      remoteDataSource.getCategories();

  @override
  Future<List<FurnitureItem>> getCategoryFurniture({required String slug}) =>
      remoteDataSource.getCategoryFurniture(slug: slug);
}
