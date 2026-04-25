import '../../../../core/network/dio_client.dart';
import '../../../home/domain/model/combination_item.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../materials/data/model/material_item.dart';
import '../../../materials/data/model/material_list_response_dto.dart';
import '../models/paginated_response.dart';

abstract class ViewAllRemoteDataSource {
  Future<PaginatedResponse<FurnitureItem>> getFurniture({
    required int page,
    required int limit,
    String? search,
  });

  Future<PaginatedResponse<CombinationItem>> getCombinations({
    required int page,
    required int limit,
    String? search,
  });

  Future<PaginatedResponse<MaterialListItem>> getMaterials({
    required int page,
    required int limit,
    String? search,
  });
}

class ViewAllRemoteDataSourceImpl implements ViewAllRemoteDataSource {
  const ViewAllRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<PaginatedResponse<FurnitureItem>> getFurniture({
    required int page,
    required int limit,
    String? search,
  }) async {
    final res = await dioClient.dio.get(
      '/api/top/furniture',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return _parsePaginated(res.data, FurnitureItem.fromJson);
  }

  @override
  Future<PaginatedResponse<CombinationItem>> getCombinations({
    required int page,
    required int limit,
    String? search,
  }) async {
    final res = await dioClient.dio.get(
      '/api/top/combinations',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return _parsePaginated(res.data, CombinationItem.fromJson);
  }

  @override
  Future<PaginatedResponse<MaterialListItem>> getMaterials({
    required int page,
    required int limit,
    String? search,
  }) async {
    final res = await dioClient.dio.get(
      '/api/materials',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final dto = MaterialListResponseDto.fromJson(
        res.data as Map<String, dynamic>);
    final domain = dto.toDomain();
    return PaginatedResponse<MaterialListItem>(
      items: domain.items,
      page: domain.page,
      totalPages: domain.totalPages,
    );
  }

  PaginatedResponse<T> _parsePaginated<T>(
    dynamic rawData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (rawData is Map<String, dynamic>) {
      final pagination =
          rawData['pagination'] as Map<String, dynamic>? ?? {};
      final data = rawData['data'] as List<dynamic>? ?? [];

      return PaginatedResponse<T>(
        items:
            data.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        page: pagination['page'] as int? ?? 1,
        totalPages: pagination['totalPages'] as int? ?? 1,
      );
    }

    if (rawData is List) {
      return PaginatedResponse<T>(
        items: rawData
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList(),
        page: 1,
        totalPages: 1,
      );
    }

    return PaginatedResponse<T>(items: [], page: 1, totalPages: 1);
  }
}
