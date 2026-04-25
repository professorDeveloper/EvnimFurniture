import '../repositories/detail_repository.dart';

class GetMyRatingUseCase {
  const GetMyRatingUseCase({required this.repository});

  final DetailRepository repository;

  Future<int?> call({required String furnitureMaterialId}) =>
      repository.getMyRating(furnitureMaterialId: furnitureMaterialId);
}
