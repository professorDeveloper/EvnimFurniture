import '../../data/model/furniture_material_colors_response.dart';
import '../repositories/home_repository.dart';

class GetFurnitureMaterialColorsUseCase {
  const GetFurnitureMaterialColorsUseCase({required this.repository});

  final HomeRepository repository;

  Future<FurnitureMaterialColorsResponse> call({
    required String furnitureMaterialId,
  }) =>
      repository.getFurnitureMaterialColors(
          furnitureMaterialId: furnitureMaterialId);
}
