import '../../../../core/services/notification_service.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  const VerifyEmailOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<bool> call({required String email, required String code}) async {
    final response = await _repository.verifyEmailOtp(
      email: email,
      code: code,
    );

    final idToken = await _repository.signInWithCustomToken(
      response.customToken,
    );

    await _repository.saveIdToken(idToken);

    NotificationService.instance.registerToken();
    NotificationService.instance.listenTokenRefresh();

    return response.isNewUser;
  }
}
