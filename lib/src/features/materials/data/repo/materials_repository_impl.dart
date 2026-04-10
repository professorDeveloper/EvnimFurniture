import '../../domain/repo/materials_repository.dart';
import '../datasource/materials_remote_datasource.dart';
import '../model/material_item.dart';

class MaterialsRepositoryImpl implements MaterialsRepository {
  const MaterialsRepositoryImpl({required this.remoteDataSource});

  final MaterialsRemoteDataSource remoteDataSource;

  @override
  Future<MaterialListResponse> getMaterials({
    required int page,
    required int limit,
    String? search,
  }) async {
    final dto = await remoteDataSource.getMaterials(
      page: page,
      limit: limit,
      search: search,
    );
    return dto.toDomain();
  }
}
