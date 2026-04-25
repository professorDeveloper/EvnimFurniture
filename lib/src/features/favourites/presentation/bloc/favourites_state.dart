part of 'favourites_bloc.dart';

@immutable
sealed class FavouritesState {}

final class FavouritesInitial extends FavouritesState {}

final class FavouritesLoading extends FavouritesState {}

final class FavouritesLoaded extends FavouritesState {
  FavouritesLoaded({required this.items});
  final List<FavouriteItem> items;
}

final class FavouritesError extends FavouritesState {
  FavouritesError({required this.message});
  final String message;
}
