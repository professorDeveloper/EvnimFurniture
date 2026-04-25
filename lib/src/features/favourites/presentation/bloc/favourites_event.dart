part of 'favourites_bloc.dart';

@immutable
sealed class FavouritesEvent {}

final class FavouritesLoadRequested extends FavouritesEvent {}

final class FavouriteRemoveRequested extends FavouritesEvent {
  FavouriteRemoveRequested({required this.furnitureMaterialId});
  final String furnitureMaterialId;
}
