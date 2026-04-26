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
    // 1. Download furniture image
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

    // 2. POST — darhol jobId qaytaradi
    final startRes = await dioClient.dio.post<Map<String, dynamic>>(
      '/api/ai-image/place-furniture',
      data: formData,
      options: dio_pkg.Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 35),
        sendTimeout: const Duration(seconds: 35),
      ),
    );

    final jobId = (startRes.data?['jobId'] as String?) ?? '';
    if (jobId.isEmpty) throw Exception('no_job_id');

    // 3. Har 3 sekundda polling, max 30 sekund
    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 3));

      final pollRes = await dioClient.dio.get<Map<String, dynamic>>(
        '/api/ai-image/place-furniture/$jobId',
      );

      final data = pollRes.data;
      final success = data?['success'] as bool? ?? false;
      final status = data?['status'] as String? ?? '';

      if (!success || status == 'error') {
        throw Exception(data?['message'] as String? ?? 'ai_error');
      }

      if (status == 'done') {
        final base64Image = (data?['data']?['image'] as String?) ?? '';
        if (base64Image.isEmpty) throw Exception('empty_result');
        return base64Image;
      }
      // status == 'processing' → davom etadi
    }

    throw Exception('timeout');
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
