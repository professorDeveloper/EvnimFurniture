import '../repositories/detail_repository.dart';

class TryInRoomUseCase {
  const TryInRoomUseCase({required this.repository});

  final DetailRepository repository;

  Future<String> call({
    required String roomImagePath,
    required String furnitureImageUrl,
  }) =>
      repository.tryInRoom(
        roomImagePath: roomImagePath,
        furnitureImageUrl: furnitureImageUrl,
      );
}
