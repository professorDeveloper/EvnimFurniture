import '../../../../core/services/notification_service.dart';
import '../model/login_response.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase {
  const SocialLoginUseCase(this._repository);
  final AuthRepository _repository;

  /// Signs in with Google/Apple via Firebase, gets idToken,
  /// saves it, then calls POST /api/auth/login.
  Future<LoginResponse> call({required String provider}) async {
    // 1. Firebase sign-in
    final userCred = provider == 'apple'
        ? await _repository.signInWithApple()
        : await _repository.signInWithGoogle();

    // 2. Call backend POST /api/auth/login with Bearer token
    final response = await _repository.socialLogin();

    // 5. Register FCM token if permission already granted
    if (NotificationService.instance.isPermissionGranted) {
      NotificationService.instance.registerToken();
      NotificationService.instance.listenTokenRefresh();
    }

    return response;
  }
}
