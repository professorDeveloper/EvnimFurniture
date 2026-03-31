import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/home_data.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required GetHomeDataUseCase useCase})
      : _useCase = useCase,
        super(const HomeInitial()) {
    on<LoadHomeData>(_onLoad);
    on<RefreshHomeData>(_onRefresh);
  }

  final GetHomeDataUseCase _useCase;

  Future<void> _onLoad(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final data = await _useCase();
      emit(HomeLoaded(data: data));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
      RefreshHomeData event, Emitter<HomeState> emit) async {
    final prev = state;
    try {
      final data = await _useCase();
      emit(HomeLoaded(data: data));
    } catch (e) {
      if (prev is HomeLoaded) {
        emit(prev);
      } else {
        emit(HomeError(message: e.toString()));
      }
    }
  }
}
