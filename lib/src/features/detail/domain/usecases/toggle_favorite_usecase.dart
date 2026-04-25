import '../repositories/detail_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase({required this.repository});

  final DetailRepository repository;

  Future<void> call({
    required String furnitureMaterialId,
    required bool isFavorite,
  }) {
    if (isFavorite) {
      return repository.addFavorite(furnitureMaterialId: furnitureMaterialId);
    }
    return repository.removeFavorite(furnitureMaterialId: furnitureMaterialId);
  }
}
