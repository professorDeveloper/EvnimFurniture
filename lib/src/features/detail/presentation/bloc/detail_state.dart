part of 'detail_bloc.dart';

@immutable
sealed class DetailState {}

final class DetailInitial extends DetailState {}

final class DetailLoading extends DetailState {}

final class DetailLoaded extends DetailState {
  DetailLoaded({required this.data, required this.currentMaterialId});
  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
}

final class DetailError extends DetailState {
  DetailError({required this.message});
  final String message;
}
