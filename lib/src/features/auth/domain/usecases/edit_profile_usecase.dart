import '../model/user_model.dart';
import '../repositories/auth_repository.dart';

class EditProfileUseCase {
  const EditProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserModel> call({String? name, String? picturePath, String? userType}) =>
      _repository.editProfile(name: name, picturePath: picturePath, userType: userType);
}
