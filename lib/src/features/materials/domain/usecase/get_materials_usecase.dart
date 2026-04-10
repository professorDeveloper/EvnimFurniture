
import '../../data/model/material_item.dart';
import '../repo/materials_repository.dart';

class GetMaterialsUseCase {
  const GetMaterialsUseCase({required this.repository});

  final MaterialsRepository repository;

  Future<MaterialListResponse> call({
    required int page,
    required int limit,
    String? search,
  }) =>
      repository.getMaterials(page: page, limit: limit, search: search);
}
