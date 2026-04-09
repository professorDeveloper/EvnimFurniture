import '../../../../core/services/notification_service.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  /// Verifies OTP, signs in with Firebase custom token,
  /// saves idToken, registers FCM, and returns whether user is new.
  Future<bool> call({required String phone, required String code}) async {
    final response = await _repository.verifyOtp(phone: phone, code: code);

    final idToken = await _repository.signInWithCustomToken(
      response.customToken,
    );

    await _repository.saveIdToken(idToken);

    // Register FCM token if permission already granted
    if (NotificationService.instance.isPermissionGranted) {
      NotificationService.instance.registerToken();
      NotificationService.instance.listenTokenRefresh();
    }

    return response.isNewUser;
  }
}
