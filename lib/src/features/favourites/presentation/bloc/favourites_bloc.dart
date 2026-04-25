import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/model/favourite_item.dart';
import '../../domain/usecases/get_favourites_usecase.dart';
import '../../domain/usecases/remove_favourite_usecase.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  FavouritesBloc({
    required this.getFavouritesUseCase,
    required this.removeFavouriteUseCase,
  }) : super(FavouritesInitial()) {
    on<FavouritesLoadRequested>(_onLoad);
    on<FavouriteRemoveRequested>(_onRemove);
  }

  final GetFavouritesUseCase getFavouritesUseCase;
  final RemoveFavouriteUseCase removeFavouriteUseCase;

  Future<void> _onLoad(
    FavouritesLoadRequested event,
    Emitter<FavouritesState> emit,
  ) async {
    emit(FavouritesLoading());
    try {
      final items = await getFavouritesUseCase();
      emit(FavouritesLoaded(items: items));
    } catch (e) {
      emit(FavouritesError(message: e.toString()));
    }
  }

  Future<void> _onRemove(
    FavouriteRemoveRequested event,
    Emitter<FavouritesState> emit,
  ) async {
    final current = state;
    if (current is! FavouritesLoaded) return;
    final updated = current.items
        .where((e) => e.furnitureMaterialId != event.furnitureMaterialId)
        .toList();
    emit(FavouritesLoaded(items: updated));
    try {
      await removeFavouriteUseCase(
          furnitureMaterialId: event.furnitureMaterialId);
    } catch (_) {
      emit(FavouritesLoaded(items: current.items));
    }
  }
}
