import '../../data/model/material_furniture_response.dart';
import '../repositories/home_repository.dart';

class GetMaterialFurnitureUseCase {
  const GetMaterialFurnitureUseCase({required this.repository});

  final HomeRepository repository;

  Future<MaterialFurnitureResponse> call({
    required String materialId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getMaterialFurniture(
      materialId: materialId,
      page: page,
      limit: limit,
    );
  }
}