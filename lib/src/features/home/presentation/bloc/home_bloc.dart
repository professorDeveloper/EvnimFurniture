import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/combination_item.dart';
import '../../domain/model/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeDataUseCase useCase, required HomeRepository repository})
      : _useCase = useCase,
        _repository = repository,
        super(const HomeInitial()) {
    on<LoadHomeData>(_onLoad);
    on<RefreshHomeData>(_onRefresh);
    on<LoadMoreCombinations>(_onLoadMore);
  }

  final GetHomeDataUseCase _useCase;
  final HomeRepository _repository;

  Future<void> _onLoad(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final data = await _useCase();
      emit(HomeLoaded(
        data: data,
        combinations: data.topCombinations,
        combinationsPage: 1,
        hasMoreCombinations: data.topCombinations.length >= 10,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshHomeData event, Emitter<HomeState> emit) async {
    final prev = state;
    try {
      final data = await _useCase();
      emit(HomeLoaded(
        data: data,
        combinations: data.topCombinations,
        combinationsPage: 1,
        hasMoreCombinations: data.topCombinations.length >= 10,
      ));
    } catch (e) {
      if (prev is HomeLoaded) {
        emit(prev);
      } else {
        emit(HomeError(message: e.toString()));
      }
    }
  }

  Future<void> _onLoadMore(LoadMoreCombinations event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is! HomeLoaded || current.loadingMoreCombinations || !current.hasMoreCombinations) return;

    emit(current.copyWith(loadingMoreCombinations: true));

    try {
      final nextPage = current.combinationsPage + 1;
      final newItems = await _repository.getTopCombinationsPaged(page: nextPage, limit: 10);

      final existingIds = current.combinations.map((e) => e.furnitureMaterialId).toSet();
      final unique = newItems.where((e) => !existingIds.contains(e.furnitureMaterialId)).toList();

      emit(current.copyWith(
        combinations: [...current.combinations, ...unique],
        combinationsPage: nextPage,
        hasMoreCombinations: unique.isNotEmpty,
        loadingMoreCombinations: false,
      ));
    } catch (_) {
      emit(current.copyWith(loadingMoreCombinations: false, hasMoreCombinations: false));
    }
  }
}
