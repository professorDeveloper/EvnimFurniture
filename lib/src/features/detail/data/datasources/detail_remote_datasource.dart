import '../../../../core/network/dio_client.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';

abstract class DetailRemoteDataSource {
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  });
}

class DetailRemoteDataSourceImpl implements DetailRemoteDataSource {
  const DetailRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  }) async {
    final res = await dioClient.dio
        .get('/api/furniture-materials/$furnitureMaterialId/colors');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return FurnitureMaterialColorsResponse.fromJson(data);
    }
    throw Exception('Unexpected response format for furniture material colors');
  }
}
