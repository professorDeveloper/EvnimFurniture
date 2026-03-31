import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/model/category_model.dart';
import '../../domain/model/combination_item.dart';
import '../../domain/model/furniture_item.dart';
import '../../domain/model/material_item.dart';
import '../../domain/model/story_item.dart';

abstract class HomeRemoteDataSource {
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10});
  Future<List<MaterialItem>> getTopMaterials({int limit = 10});
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20});
  Future<List<CategoryItem>> getCategories();
  Future<List<CombinationItem>> getTopCombinations({int limit = 10});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10}) async {
    final Response res = await dioClient.dio
        .get('/api/top/furniture', queryParameters: {'limit': limit});
    return _parseList(res, FurnitureItem.fromJson);
  }

  @override
  Future<List<MaterialItem>> getTopMaterials({int limit = 10}) async {
    final Response res = await dioClient.dio
        .get('/api/top/materials', queryParameters: {'limit': limit});
    return _parseList(res, MaterialItem.fromJson);
  }

  @override
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20}) async {
    final Response res = await dioClient.dio.get(
      '/api/stories',
      queryParameters: {'page': page, 'limit': limit},
    );
    return _parseList(res, StoryItem.fromJson);
  }

  @override
  Future<List<CategoryItem>> getCategories() async {
    final Response res = await dioClient.dio.get('/api/categories');
    return _parseList(res, CategoryItem.fromJson);
  }

  @override
  Future<List<CombinationItem>> getTopCombinations({int limit = 10}) async {
    final Response res = await dioClient.dio
        .get('/api/top/combinations', queryParameters: {'limit': limit});
    return _parseList(res, CombinationItem.fromJson);
  }

  List<T> _parseList<T>(
      Response res,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final dynamic rawData = res.data;
    if (rawData is List) {
      return rawData.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    if (rawData is Map && rawData.containsKey('data')) {
      final List<dynamic> data = rawData['data'] as List<dynamic>;
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
