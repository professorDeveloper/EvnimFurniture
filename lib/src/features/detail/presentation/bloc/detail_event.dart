part of 'detail_bloc.dart';

@immutable
sealed class DetailEvent {}

final class DetailFetchRequested extends DetailEvent {
  DetailFetchRequested({required this.furnitureMaterialId});
  final String furnitureMaterialId;
}

final class DetailMyRatingRequested extends DetailEvent {
  DetailMyRatingRequested({required this.furnitureMaterialId});
  final String furnitureMaterialId;
}

final class DetailRateSubmitted extends DetailEvent {
  DetailRateSubmitted({
    required this.furnitureMaterialId,
    required this.score,
  });
  final String furnitureMaterialId;
  final int score;
}

final class DetailTryInRoomRequested extends DetailEvent {
  DetailTryInRoomRequested({
    required this.roomImagePath,
    required this.furnitureImageUrl,
  });
  final String roomImagePath;
  final String furnitureImageUrl;
}

final class DetailTryInRoomCancelled extends DetailEvent {}

final class DetailFavoriteToggled extends DetailEvent {
  DetailFavoriteToggled({required this.furnitureMaterialId});
  final String furnitureMaterialId;
}
