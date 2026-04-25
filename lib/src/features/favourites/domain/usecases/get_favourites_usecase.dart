import '../model/favourite_item.dart';
import '../repositories/favourites_repository.dart';

class GetFavouritesUseCase {
  const GetFavouritesUseCase({required this.repository});

  final FavouritesRepository repository;

  Future<List<FavouriteItem>> call() => repository.getFavourites();
}
