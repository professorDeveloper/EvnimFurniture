part of 'detail_bloc.dart';

@immutable
sealed class DetailState {}

final class DetailInitial extends DetailState {}

final class DetailLoading extends DetailState {}

final class DetailLoaded extends DetailState {
  DetailLoaded({
    required this.data,
    required this.currentMaterialId,
    this.myRating,
    this.isFavorite = false,
  });
  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
  final int? myRating;
  final bool isFavorite;
}

final class DetailError extends DetailState {
  DetailError({required this.message});
  final String message;
}

final class DetailAiProcessing extends DetailState {
  DetailAiProcessing({required this.data, required this.currentMaterialId});
  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
}

final class DetailAiSuccess extends DetailState {
  DetailAiSuccess({
    required this.base64Image,
    required this.data,
    required this.currentMaterialId,
    this.myRating,
  });
  final String base64Image;
  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
  final int? myRating;
}

final class DetailAiError extends DetailState {
  DetailAiError({
    required this.message,
    required this.data,
    required this.currentMaterialId,
    this.myRating,
  });
  final String message;
  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
  final int? myRating;
}
