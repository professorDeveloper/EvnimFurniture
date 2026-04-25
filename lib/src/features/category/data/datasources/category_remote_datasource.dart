import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../domain/model/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryItem>> getCategories();
  Future<List<FurnitureItem>> getCategoryFurniture({required String slug});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  const CategoryRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<CategoryItem>> getCategories() async {
    final Response res = await dioClient.dio.get('/api/categories');
    final dynamic raw = res.data;
    List<dynamic> list;
    if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }
    return list
        .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FurnitureItem>> getCategoryFurniture({
    required String slug,
  }) async {
    final Response res = await dioClient.dio.get('/api/categories/$slug');
    final data = res.data as Map<String, dynamic>;
    final list = data['furniture'] as List<dynamic>? ?? [];
    return list
        .map((e) => FurnitureItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
