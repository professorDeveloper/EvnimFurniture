import '../../../home/data/model/furniture_material_colors_response.dart';
import '../model/rating_result.dart';

abstract class DetailRepository {
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
