import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/notification_item.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({required GetNotificationsUseCase useCase})
      : _useCase = useCase,
        super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<LoadMoreNotifications>(_onLoadMore);
    on<RefreshNotifications>(_onRefresh);
  }

  final GetNotificationsUseCase _useCase;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final page = await _useCase(page: 1);
      emit(NotificationLoaded(
        items: page.items,
        currentPage: page.page,
        totalPages: page.pages,
      ));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded || !current.hasMore) return;
    if (current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _useCase(page: current.currentPage + 1);
      emit(NotificationLoaded(
        items: [...current.items, ...page.items],
        currentPage: page.page,
        totalPages: page.pages,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final page = await _useCase(page: 1);
      emit(NotificationLoaded(
        items: page.items,
        currentPage: page.page,
        totalPages: page.pages,
      ));
    } catch (e) {
      if (state is NotificationLoaded) return;
      emit(NotificationError(message: e.toString()));
    }
  }
}
