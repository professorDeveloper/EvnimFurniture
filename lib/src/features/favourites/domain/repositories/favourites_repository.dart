import '../model/favourite_item.dart';

abstract class FavouritesRepository {
  Future<List<FavouriteItem>> getFavourites();
  Future<void> removeFavourite({required String furnitureMaterialId});
}
