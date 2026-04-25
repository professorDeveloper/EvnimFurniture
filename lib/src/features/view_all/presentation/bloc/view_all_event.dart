part of 'view_all_bloc.dart';

@immutable
abstract class ViewAllEvent {}

class ViewAllFetched extends ViewAllEvent {
  ViewAllFetched({this.search});
  final String? search;
}

class ViewAllNextPageFetched extends ViewAllEvent {}

class ViewAllSearchChanged extends ViewAllEvent {
  ViewAllSearchChanged({required this.query});
  final String query;
}
