part of 'materials_bloc.dart';

@immutable
sealed class MaterialsState {}

final class MaterialsInitial extends MaterialsState {}

final class MaterialsLoading extends MaterialsState {}

final class MaterialsLoaded extends MaterialsState {
  MaterialsLoaded({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.search,
    this.isPaginating = false,
  });

  final List<MaterialListItem> items;
  final int currentPage;
  final int totalPages;
  final String search;
  final bool isPaginating;

  bool get hasMore => currentPage < totalPages;

  MaterialsLoaded copyWith({
    List<MaterialListItem>? items,
    int? currentPage,
    int? totalPages,
    String? search,
    bool? isPaginating,
  }) =>
      MaterialsLoaded(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        search: search ?? this.search,
        isPaginating: isPaginating ?? this.isPaginating,
      );
}

final class MaterialsFailure extends MaterialsState {
  MaterialsFailure({required this.message});
  final String message;
}
