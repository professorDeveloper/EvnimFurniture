import '../../domain/model/category_model.dart';
import '../../domain/model/combination_item.dart';
import '../../domain/model/furniture_item.dart';
import '../../domain/model/material_item.dart';
import '../../domain/model/story_item.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.remoteDataSource});

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10}) =>
      remoteDataSource.getTopFurniture(limit: limit);

  @override
  Future<List<MaterialItem>> getTopMaterials({int limit = 10}) =>
      remoteDataSource.getTopMaterials(limit: limit);

  @override
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20}) =>
      remoteDataSource.getStories(page: page, limit: limit);

  @override
  Future<List<CategoryItem>> getCategories() =>
      remoteDataSource.getCategories();

  @override
  Future<List<CombinationItem>> getTopCombinations({int limit = 10}) =>
      remoteDataSource.getTopCombinations(limit: limit);
}
