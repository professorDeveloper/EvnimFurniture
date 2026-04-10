import '../model/user_model.dart';
import '../repositories/auth_repository.dart';

class GetMeUseCase {
  const GetMeUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserModel> call() => _repository.getMe();
}
