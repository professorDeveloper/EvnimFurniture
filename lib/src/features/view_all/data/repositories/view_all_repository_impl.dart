import '../../../home/domain/model/combination_item.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../materials/data/model/material_item.dart';
import '../../domain/repositories/view_all_repository.dart';
import '../datasources/view_all_remote_datasource.dart';
import '../models/paginated_response.dart';

class ViewAllRepositoryImpl implements ViewAllRepository {
  const ViewAllRepositoryImpl({required this.remoteDataSource});

  final ViewAllRemoteDataSource remoteDataSource;

  @override
  Future<PaginatedResponse<FurnitureItem>> getFurniture({
    required int page,
    required int limit,
    String? search,
  }) =>
      remoteDataSource.getFurniture(page: page, limit: limit, search: search);

  @override
  Future<PaginatedResponse<CombinationItem>> getCombinations({
    required int page,
    required int limit,
    String? search,
  }) =>
      remoteDataSource.getCombinations(
          page: page, limit: limit, search: search);

  @override
  Future<PaginatedResponse<MaterialListItem>> getMaterials({
    required int page,
    required int limit,
    String? search,
  }) =>
      remoteDataSource.getMaterials(page: page, limit: limit, search: search);
}
