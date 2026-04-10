import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/material_item.dart';
import '../../domain/usecase/get_materials_usecase.dart';


part 'materials_event.dart';
part 'materials_state.dart';

class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  Timer? _debounce;

  MaterialsBloc({required this.useCase}) : super(MaterialsInitial()) {
    on<MaterialsFetched>(_onFetched);
    on<MaterialsNextPageFetched>(_onNextPage);
    on<MaterialsSearchChanged>(_onSearchChanged,);
  }

  final GetMaterialsUseCase useCase;

  static const int _limit = 20;


  Future<void> _onFetched(
    MaterialsFetched event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    try {
      final result = await useCase(
        page: 1,
        limit: _limit,
        search: event.search,
      );
      emit(MaterialsLoaded(
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        search: event.search ?? '',
      ));
    } catch (e) {
      emit(MaterialsFailure(message: e.toString()));
    }
  }

  Future<void> _onNextPage(
    MaterialsNextPageFetched event,
    Emitter<MaterialsState> emit,
  ) async {
    final current = state;
    if (current is! MaterialsLoaded || !current.hasMore || current.isPaginating) {
      return;
    }
    emit(current.copyWith(isPaginating: true));
    try {
      final result = await useCase(
        page: current.currentPage + 1,
        limit: _limit,
        search: current.search.isEmpty ? null : current.search,
      );
      emit(current.copyWith(
        items: [...current.items, ...result.items],
        currentPage: result.page,
        totalPages: result.totalPages,
        isPaginating: false,
      ));
    } catch (_) {
      emit(current.copyWith(isPaginating: false));
    }
  }

  Future<void> _onSearchChanged(
    MaterialsSearchChanged event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    try {
      final result = await useCase(
        page: 1,
        limit: _limit,
        search: event.query.isEmpty ? null : event.query,
      );
      emit(MaterialsLoaded(
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        search: event.query,
      ));
    } catch (e) {
      emit(MaterialsFailure(message: e.toString()));
    }
  }
}
