import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/model/banner_item.dart';
import '../../domain/model/category_model.dart';
import '../../domain/model/combination_item.dart';
import '../../domain/model/furniture_item.dart';
import '../../domain/model/material_item.dart';
import '../../domain/model/story_item.dart';
import '../model/banner_response.dart';
import '../model/furniture_detail_response.dart';
import '../model/furniture_material_colors_response.dart';
import '../model/material_furniture_response.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerItem>> getBanners();
  Future<List<FurnitureItem>> getTopFurniture({int limit = 10});
  Future<List<MaterialItem>> getTopMaterials({int limit = 10});
  Future<List<StoryItem>> getStories({int page = 1, int limit = 20});
  Future<List<CategoryItem>> getCategories();
  Future<List<CombinationItem>> getTopCombinations({int limit = 10, int page = 1});

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

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<BannerItem>> getBanners() async {
    final Response res = await dioClient.dio.get('/api/banners');
    final dynamic rawData = res.data;

    if (rawData is Map && rawData.containsKey('data')) {
      final List<dynamic> data = rawData['data'] as List<dynamic>;
      return data
          .map((e) => BannerResponse.fromJson(e as Map<String, dynamic>))
          .map((banner) => BannerItem(
                id: banner.id,
                imageUrl: banner.image,
                furnitureMaterialId: banner.furnitureMaterialId,
                order: banner.order,
              ))
          .toList();
    }
    return [];
  }

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
  Future<List<CombinationItem>> getTopCombinations({int limit = 10, int page = 1}) async {
    final Response res = await dioClient.dio
        .get('/api/top/combinations', queryParameters: {'limit': limit, 'page': page});
    return _parseList(res, CombinationItem.fromJson);
  }

  @override
  Future<MaterialFurnitureResponse> getMaterialFurniture({
    required String materialId,
    int page = 1,
    int limit = 20,
  }) async {
    final Response res = await dioClient.dio.get(
      '/api/materials/$materialId/furniture',
      queryParameters: {'page': page, 'limit': limit},
    );
    final dynamic rawData = res.data;
    if (rawData is Map<String, dynamic>) {
      return MaterialFurnitureResponse.fromJson(rawData);
    }
    throw Exception('Unexpected response format for material furniture');
  }

  @override
  Future<FurnitureDetailResponse> getFurnitureDetail({
    required String furnitureId,
  }) async {
    final Response res =
        await dioClient.dio.get('/api/furniture/$furnitureId');
    final dynamic rawData = res.data;
    if (rawData is Map<String, dynamic>) {
      return FurnitureDetailResponse.fromJson(rawData);
    }
    throw Exception('Unexpected response format for furniture detail');
  }

  @override
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  }) async {
    final Response res = await dioClient.dio
        .get('/api/furniture-materials/$furnitureMaterialId/colors');
    final dynamic rawData = res.data;
    if (rawData is Map<String, dynamic>) {
      return FurnitureMaterialColorsResponse.fromJson(rawData);
    }
    throw Exception('Unexpected response format for furniture material colors');
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