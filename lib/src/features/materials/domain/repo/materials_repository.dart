
import '../../data/model/material_item.dart';

abstract class MaterialsRepository {
  Future<MaterialListResponse> getMaterials({
    required int page,
    required int limit,
    String? search,
  });
}
