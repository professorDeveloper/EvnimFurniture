import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/model/login_response.dart';
import '../../domain/model/otp_response.dart';
import '../../domain/model/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
    required this.secureStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;
  final FlutterSecureStorage secureStorage;

  static const _idTokenKey = 'id_token';

  // Phone OTP
  @override
  Future<SendOtpResponse> sendOtp({required String phone}) =>
      remoteDataSource.sendOtp(phone: phone);

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
  }) =>
      remoteDataSource.verifyOtp(phone: phone, code: code);

  @override
  Future<SendOtpResponse> resendOtp({required String phone}) =>
      remoteDataSource.resendOtp(phone: phone);

  // Email OTP
  @override
  Future<SendOtpResponse> sendEmailOtp({required String email}) =>
      remoteDataSource.sendEmailOtp(email: email);

  @override
  Future<VerifyOtpResponse> verifyEmailOtp({
    required String email,
    required String code,
  }) =>
      remoteDataSource.verifyEmailOtp(email: email, code: code);

  // Firebase + Token
  @override
  Future<String> signInWithCustomToken(String customToken) async {
    final credential = await firebaseAuth.signInWithCustomToken(customToken);
    final idToken = await credential.user!.getIdToken();
    return idToken!;
  }

  @override
  Future<void> saveIdToken(String idToken) async {
    await secureStorage.write(key: _idTokenKey, value: idToken);
  }

  @override
  Future<String?> getIdToken() async {
    return secureStorage.read(key: _idTokenKey);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await secureStorage.delete(key: _idTokenKey);
  }

  // Social login
  @override
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final googleUser = await googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) throw Exception('Google sign-in failed: no idToken');
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<LoginResponse> socialLogin() => remoteDataSource.socialLogin();

  // Profile
  @override
  Future<UserModel> completeProfile({
    required String name,
    required String userType,
    String? picturePath,
  }) =>
      remoteDataSource.completeProfile(
        name: name,
        userType: userType,
        picturePath: picturePath,
      );

  @override
  Future<UserModel> editProfile({String? name, String? picturePath, String? userType}) =>
      remoteDataSource.editProfile(name: name, picturePath: picturePath, userType: userType);

  // User
  @override
  Future<UserModel> getMe() => remoteDataSource.getMe();
}
