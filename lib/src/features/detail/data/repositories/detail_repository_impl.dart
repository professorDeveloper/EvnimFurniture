import '../../../home/data/model/furniture_material_colors_response.dart';
import '../../domain/model/rating_result.dart';
import '../../domain/repositories/detail_repository.dart';
import '../datasources/detail_remote_datasource.dart';

class DetailRepositoryImpl implements DetailRepository {
  const DetailRepositoryImpl({required this.remoteDataSource});

  final DetailRemoteDataSource remoteDataSource;

  @override
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  }) =>
      remoteDataSource.getFurnitureMaterialColors(
        furnitureMaterialId: furnitureMaterialId,
      );

  @override
  Future<int?> getMyRating({required String furnitureMaterialId}) =>
      remoteDataSource.getMyRating(furnitureMaterialId: furnitureMaterialId);

  @override
  Future<RatingResult> rateFurnitureMaterial({
    required String furnitureMaterialId,
    required int score,
  }) =>
      remoteDataSource.rateFurnitureMaterial(
        furnitureMaterialId: furnitureMaterialId,
        score: score,
      );

  @override
  Future<String> tryInRoom({
    required String roomImagePath,
    required String furnitureImageUrl,
  }) =>
      remoteDataSource.tryInRoom(
        roomImagePath: roomImagePath,
        furnitureImageUrl: furnitureImageUrl,
      );

  @override
  Future<void> addFavorite({required String furnitureMaterialId}) =>
      remoteDataSource.addFavorite(furnitureMaterialId: furnitureMaterialId);

  @override
  Future<void> removeFavorite({required String furnitureMaterialId}) =>
      remoteDataSource.removeFavorite(
          furnitureMaterialId: furnitureMaterialId);
}
