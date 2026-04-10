import '../../../home/data/model/furniture_material_colors_response.dart';
import '../repositories/detail_repository.dart';

class GetDetailColorsUseCase {
  const GetDetailColorsUseCase({required this.repository});

  final DetailRepository repository;

  Future<FurnitureMaterialColorsResponse> call({
    required String furnitureMaterialId,
  }) =>
      repository.getFurnitureMaterialColors(
        furnitureMaterialId: furnitureMaterialId,
      );
}
