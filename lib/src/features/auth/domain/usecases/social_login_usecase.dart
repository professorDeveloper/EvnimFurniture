import '../../../../core/services/notification_service.dart';
import '../model/login_response.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase {
  const SocialLoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<({LoginResponse response, String? displayName})> call({required String provider}) async {
    String? displayName;
    if (provider == 'apple') {
      final userCred = await _repository.signInWithApple();
      displayName = userCred.user?.displayName;
    } else {
      await _repository.signInWithGoogle();
    }

    final response = await _repository.socialLogin();

    if (NotificationService.instance.isPermissionGranted) {
      NotificationService.instance.registerToken();
      NotificationService.instance.listenTokenRefresh();
    }

    return (response: response, displayName: displayName);
  }
}
