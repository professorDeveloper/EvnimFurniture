import '../model/rating_result.dart';
import '../repositories/detail_repository.dart';

class RateFurnitureMaterialUseCase {
  const RateFurnitureMaterialUseCase({required this.repository});

  final DetailRepository repository;

  Future<RatingResult> call({
    required String furnitureMaterialId,
    required int score,
  }) =>
      repository.rateFurnitureMaterial(
        furnitureMaterialId: furnitureMaterialId,
        score: score,
      );
}
