import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc({required GetCategoriesUseCase useCase})
      : _useCase = useCase,
        super(const CategoriesInitial()) {
    on<LoadCategories>(_onLoad);
  }

  final GetCategoriesUseCase _useCase;

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await _useCase();
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(CategoriesError(message: e.toString()));
    }
  }
}
