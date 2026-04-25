import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/models/paginated_response.dart';
import '../../domain/repositories/view_all_repository.dart';
import '../screens/view_all_screen.dart';

part 'view_all_event.dart';
part 'view_all_state.dart';

class ViewAllBloc extends Bloc<ViewAllEvent, ViewAllState> {
  ViewAllBloc({
    required this.repository,
    required this.type,
  }) : super(ViewAllInitial()) {
    on<ViewAllFetched>(_onFetched);
    on<ViewAllNextPageFetched>(_onNextPage);
    on<ViewAllSearchChanged>(_onSearchChanged);
  }

  final ViewAllRepository repository;
  final ViewAllType type;

  static const int _limit = 20;

  Future<PaginatedResponse> _fetch({
    required int page,
    String? search,
  }) {
    switch (type) {
      case ViewAllType.furnitures:
        return repository.getFurniture(
            page: page, limit: _limit, search: search);
      case ViewAllType.combinations:
        return repository.getCombinations(
            page: page, limit: _limit, search: search);
      case ViewAllType.materials:
        return repository.getMaterials(
            page: page, limit: _limit, search: search);
    }
  }

  Future<void> _onFetched(
    ViewAllFetched event,
    Emitter<ViewAllState> emit,
  ) async {
    emit(ViewAllLoading());
    try {
      final result = await _fetch(page: 1, search: event.search);
      emit(ViewAllLoaded(
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        search: event.search ?? '',
      ));
    } catch (e) {
      emit(ViewAllFailure(message: e.toString()));
    }
  }

  Future<void> _onNextPage(
    ViewAllNextPageFetched event,
    Emitter<ViewAllState> emit,
  ) async {
    final current = state;
    if (current is! ViewAllLoaded ||
        !current.hasMore ||
        current.isPaginating) {
      return;
    }
    emit(current.copyWith(isPaginating: true));
    try {
      final result = await _fetch(
        page: current.currentPage + 1,
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
    ViewAllSearchChanged event,
    Emitter<ViewAllState> emit,
  ) async {
    emit(ViewAllLoading());
    try {
      final result = await _fetch(
        page: 1,
        search: event.query.isEmpty ? null : event.query,
      );
      emit(ViewAllLoaded(
        items: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        search: event.query,
      ));
    } catch (e) {
      emit(ViewAllFailure(message: e.toString()));
    }
  }
}
