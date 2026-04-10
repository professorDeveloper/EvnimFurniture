part of 'detail_bloc.dart';

@immutable
sealed class DetailEvent {}

final class DetailFetchRequested extends DetailEvent {
  DetailFetchRequested({required this.furnitureMaterialId});
  final String furnitureMaterialId;
}
