import '../../data/model/furniture_detail_response.dart';
import '../repositories/home_repository.dart';

class GetFurnitureDetailUseCase {
  const GetFurnitureDetailUseCase({required this.repository});

  final HomeRepository repository;

  Future<FurnitureDetailResponse> call({required String furnitureId}) =>
      repository.getFurnitureDetail(furnitureId: furnitureId);
}
