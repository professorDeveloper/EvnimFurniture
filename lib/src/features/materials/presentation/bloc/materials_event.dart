part of 'materials_bloc.dart';

@immutable
sealed class MaterialsEvent {}

final class MaterialsFetched extends MaterialsEvent {
  MaterialsFetched({this.search});
  final String? search;
}

final class MaterialsNextPageFetched extends MaterialsEvent {}

final class MaterialsSearchChanged extends MaterialsEvent {
  MaterialsSearchChanged({required this.query});
  final String query;
}
