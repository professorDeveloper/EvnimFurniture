import '../repositories/favourites_repository.dart';

class RemoveFavouriteUseCase {
  const RemoveFavouriteUseCase({required this.repository});

  final FavouritesRepository repository;

  Future<void> call({required String furnitureMaterialId}) =>
      repository.removeFavourite(furnitureMaterialId: furnitureMaterialId);
}
