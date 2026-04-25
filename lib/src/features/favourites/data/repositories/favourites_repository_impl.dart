import '../../domain/model/favourite_item.dart';
import '../../domain/repositories/favourites_repository.dart';
import '../datasources/favourites_remote_datasource.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  const FavouritesRepositoryImpl({required this.remoteDataSource});

  final FavouritesRemoteDataSource remoteDataSource;

  @override
  Future<List<FavouriteItem>> getFavourites() =>
      remoteDataSource.getFavourites();

  @override
  Future<void> removeFavourite({required String furnitureMaterialId}) =>
      remoteDataSource.removeFavourite(
          furnitureMaterialId: furnitureMaterialId);
}
