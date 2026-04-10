import '../../../../core/network/dio_client.dart';
import '../model/material_list_response_dto.dart';

abstract class MaterialsRemoteDataSource {
  Future<MaterialListResponseDto> getMaterials({
    required int page,
    required int limit,
    String? search,
  });
}

class MaterialsRemoteDataSourceImpl implements MaterialsRemoteDataSource {
  const MaterialsRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<MaterialListResponseDto> getMaterials({
    required int page,
    required int limit,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await dioClient.dio.get(
      'api/materials',
      queryParameters: queryParams,
    );

    return MaterialListResponseDto.fromJson(
        response.data as Map<String, dynamic>);
  }
}
