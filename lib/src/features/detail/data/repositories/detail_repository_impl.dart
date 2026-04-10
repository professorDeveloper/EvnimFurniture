import '../../../home/data/model/furniture_material_colors_response.dart';
import '../../domain/repositories/detail_repository.dart';
import '../datasources/detail_remote_datasource.dart';

class DetailRepositoryImpl implements DetailRepository {
  const DetailRepositoryImpl({required this.remoteDataSource});

  final DetailRemoteDataSource remoteDataSource;

  @override
  Future<FurnitureMaterialColorsResponse> getFurnitureMaterialColors({
    required String furnitureMaterialId,
  }) =>
      remoteDataSource.getFurnitureMaterialColors(
        furnitureMaterialId: furnitureMaterialId,
      );
}
