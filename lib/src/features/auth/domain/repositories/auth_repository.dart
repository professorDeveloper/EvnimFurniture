import 'package:firebase_auth/firebase_auth.dart';

import '../model/login_response.dart';
import '../model/otp_response.dart';
import '../model/user_model.dart';

abstract class AuthRepository {
  // Phone OTP
  Future<SendOtpResponse> sendOtp({required String phone});
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
  });
  Future<SendOtpResponse> resendOtp({required String phone});

  // Email OTP
  Future<SendOtpResponse> sendEmailOtp({required String email});
  Future<VerifyOtpResponse> verifyEmailOtp({
    required String email,
    required String code,
  });

  // Firebase + Token
  Future<String> signInWithCustomToken(String customToken);
  Future<void> saveIdToken(String idToken);
  Future<String?> getIdToken();
  Future<void> logout();

  // Social login
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<LoginResponse> socialLogin();

  // Profile
  Future<UserModel> completeProfile({
    required String name,
    required String userType,
    String? picturePath,
  });
  Future<UserModel> editProfile({String? name, String? picturePath, String? userType});

  // User
  Future<UserModel> getMe();
}
