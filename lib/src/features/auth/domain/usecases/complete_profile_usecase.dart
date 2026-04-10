import '../model/user_model.dart';
import '../repositories/auth_repository.dart';

class CompleteProfileUseCase {
  const CompleteProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserModel> call({
    required String name,
    required String userType,
    String? picturePath,
  }) =>
      _repository.completeProfile(
        name: name,
        userType: userType,
        picturePath: picturePath,
      );
}
