import '../../../home/domain/model/combination_item.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../materials/data/model/material_item.dart';
import '../../data/models/paginated_response.dart';

abstract class ViewAllRepository {
  Future<PaginatedResponse<FurnitureItem>> getFurniture({
    required int page,
    required int limit,
    String? search,
  });

  Future<PaginatedResponse<CombinationItem>> getCombinations({
    required int page,
    required int limit,
    String? search,
  });

  Future<PaginatedResponse<MaterialListItem>> getMaterials({
    required int page,
    required int limit,
    String? search,
  });
}
