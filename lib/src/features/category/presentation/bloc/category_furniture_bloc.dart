import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_category_furniture_usecase.dart';
import 'category_furniture_event.dart';
import 'category_furniture_state.dart';

class CategoryFurnitureBloc
    extends Bloc<CategoryFurnitureEvent, CategoryFurnitureState> {
  CategoryFurnitureBloc({required GetCategoryFurnitureUseCase useCase})
      : _useCase = useCase,
        super(const CategoryFurnitureInitial()) {
    on<LoadCategoryFurniture>(_onLoad);
    on<RefreshCategoryFurniture>(_onRefresh);
    on<SearchCategoryFurniture>(_onSearch);
  }

  final GetCategoryFurnitureUseCase _useCase;

  Future<void> _onLoad(
    LoadCategoryFurniture event,
    Emitter<CategoryFurnitureState> emit,
  ) async {
    emit(const CategoryFurnitureLoading());
    try {
      final items = await _useCase(slug: event.slug);
      emit(CategoryFurnitureLoaded(allItems: items, filteredItems: items));
    } catch (e) {
      emit(CategoryFurnitureError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshCategoryFurniture event,
    Emitter<CategoryFurnitureState> emit,
  ) async {
    final prev = state;
    try {
      final items = await _useCase(slug: event.slug);
      emit(CategoryFurnitureLoaded(allItems: items, filteredItems: items));
    } catch (e) {
      if (prev is CategoryFurnitureLoaded) {
        emit(prev);
      } else {
        emit(CategoryFurnitureError(message: e.toString()));
      }
    }
  }

  void _onSearch(
    SearchCategoryFurniture event,
    Emitter<CategoryFurnitureState> emit,
  ) {
    final current = state;
    if (current is! CategoryFurnitureLoaded) return;

    final query = event.query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? current.allItems
        : current.allItems
            .where((e) => e.name.toLowerCase().contains(query))
            .toList();

    emit(CategoryFurnitureLoaded(
      allItems: current.allItems,
      filteredItems: filtered,
      query: query,
    ));
  }
}
