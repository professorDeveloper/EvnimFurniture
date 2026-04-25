part of 'view_all_bloc.dart';

@immutable
abstract class ViewAllState {}

class ViewAllInitial extends ViewAllState {}

class ViewAllLoading extends ViewAllState {}

class ViewAllLoaded extends ViewAllState {
  ViewAllLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.search = '',
    this.isPaginating = false,
  });

  final List<dynamic> items;
  final int currentPage;
  final int totalPages;
  final String search;
  final bool isPaginating;

  bool get hasMore => currentPage < totalPages;

  ViewAllLoaded copyWith({
    List<dynamic>? items,
    int? currentPage,
    int? totalPages,
    String? search,
    bool? isPaginating,
  }) {
    return ViewAllLoaded(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }
}

class ViewAllFailure extends ViewAllState {
  ViewAllFailure({required this.message});
  final String message;
}
