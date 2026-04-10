import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../home/data/model/furniture_material_colors_response.dart';
import '../../domain/usecases/get_detail_colors_usecase.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc({required this.useCase}) : super(DetailInitial()) {
    on<DetailFetchRequested>(_onFetchRequested);
  }

  final GetDetailColorsUseCase useCase;

  Future<void> _onFetchRequested(
    DetailFetchRequested event,
    Emitter<DetailState> emit,
  ) async {
    emit(DetailLoading());
    try {
      final data = await useCase(
        furnitureMaterialId: event.furnitureMaterialId,
      );
      emit(DetailLoaded(
        data: data,
        currentMaterialId: event.furnitureMaterialId,
      ));
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }
}
