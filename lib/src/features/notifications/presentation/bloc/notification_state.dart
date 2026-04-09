part of 'notification_bloc.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final List<NotificationItem> items;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => currentPage < totalPages;

  NotificationLoaded copyWith({
    List<NotificationItem>? items,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) =>
      NotificationLoaded(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class NotificationError extends NotificationState {
  const NotificationError({required this.message});
  final String message;
}
