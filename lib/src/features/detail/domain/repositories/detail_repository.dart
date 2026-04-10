import '../../../home/data/model/furniture_material_colors_response.dart';

abstract class DetailRepository {
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  });
}
