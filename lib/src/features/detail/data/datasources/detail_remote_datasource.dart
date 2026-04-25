import 'dart:typed_data';

import 'package:dio/dio.dart' as dio_pkg;

import '../../../../core/network/dio_client.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';
import '../../domain/model/rating_result.dart';

abstract class DetailRemoteDataSource {
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  });

  Future<int?> getMyRating({required String furnitureMaterialId});

  Future<RatingResult> rateFurnitureMaterial({
    required String furnitureMaterialId,
    required int score,
  });

  Future<String> tryInRoom({
    required String roomImagePath,
    required String furnitureImageUrl,
  });

  Future<void> addFavorite({required String furnitureMaterialId});

  Future<void> removeFavorite({required String furnitureMaterialId});
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

  @override
  Future<int?> getMyRating({required String furnitureMaterialId}) async {
    final res = await dioClient.dio
        .get('/api/furniture-materials/$furnitureMaterialId/my-rating');
    final data = res.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return (data['data'] as Map<String, dynamic>?)?['score'] as int?;
    }
    return null;
  }

  @override
  Future<RatingResult> rateFurnitureMaterial({
    required String furnitureMaterialId,
    required int score,
  }) async {
    final res = await dioClient.dio.post(
      '/api/furniture-materials/$furnitureMaterialId/rate',
      data: {'score': score},
    );
    final data = res.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return RatingResult.fromJson(data);
    }
    throw Exception('Failed to submit rating');
  }

  @override
  Future<String> tryInRoom({
    required String roomImagePath,
    required String furnitureImageUrl,
  }) async {
    Uint8List furnitureBytes = Uint8List(0);
    if (furnitureImageUrl.isNotEmpty) {
      final res = await dio_pkg.Dio().get<List<int>>(
        furnitureImageUrl,
        options: dio_pkg.Options(responseType: dio_pkg.ResponseType.bytes),
      );
      furnitureBytes = Uint8List.fromList(res.data ?? []);
    }

    final formData = dio_pkg.FormData.fromMap({
      'room': await dio_pkg.MultipartFile.fromFile(
        roomImagePath,
        filename: 'room.jpg',
      ),
      'furniture': dio_pkg.MultipartFile.fromBytes(
        furnitureBytes,
        filename: 'furniture.jpg',
      ),
    });

    final response = await dioClient.dio.post<Map<String, dynamic>>(
      '/api/ai-image/place-furniture',
      data: formData,
      options: dio_pkg.Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    final base64Image =
        (response.data?['data']?['image'] as String?) ?? '';
    if (base64Image.isEmpty) {
      throw Exception('empty_result');
    }
    return base64Image;
  }

  @override
  Future<void> addFavorite({required String furnitureMaterialId}) async {
    await dioClient.dio.post(
      '/api/favorites',
      data: {'furnitureMaterialId': furnitureMaterialId},
    );
  }

  @override
  Future<void> removeFavorite({required String furnitureMaterialId}) async {
    await dioClient.dio.delete('/api/favorites/$furnitureMaterialId');
  }
}
