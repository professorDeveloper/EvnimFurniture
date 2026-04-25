import '../../../../core/network/dio_client.dart';
import '../../domain/model/favourite_item.dart';

abstract class FavouritesRemoteDataSource {
  Future<List<FavouriteItem>> getFavourites();
  Future<void> removeFavourite({required String furnitureMaterialId});
}

class FavouritesRemoteDataSourceImpl implements FavouritesRemoteDataSource {
  const FavouritesRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<FavouriteItem>> getFavourites() async {
    final res = await dioClient.dio.get('/api/favorites');
    final data = res.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(FavouriteItem.fromJson)
          .toList();
    }
    return [];
  }

  @override
  Future<void> removeFavourite({required String furnitureMaterialId}) async {
    await dioClient.dio.delete('/api/favorites/$furnitureMaterialId');
  }
}
