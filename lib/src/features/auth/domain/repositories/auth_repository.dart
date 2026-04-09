import '../model/otp_response.dart';

abstract class AuthRepository {
  Future<SendOtpResponse> sendOtp({required String phone});
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
  });
  Future<SendOtpResponse> resendOtp({required String phone});
  Future<String> signInWithCustomToken(String customToken);
  Future<void> saveIdToken(String idToken);
  Future<String?> getIdToken();
  Future<void> logout();
}
