import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  /// Verifies OTP, signs in with Firebase custom token,
  /// saves idToken, and returns whether user is new.
  Future<bool> call({required String phone, required String code}) async {
    final response = await _repository.verifyOtp(phone: phone, code: code);

    final idToken = await _repository.signInWithCustomToken(
      response.customToken,
    );

    await _repository.saveIdToken(idToken);

    return response.isNewUser;
  }
}
