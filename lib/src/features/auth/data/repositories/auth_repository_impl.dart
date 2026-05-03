import 'package:firebase_auth/firebase_auth.dart';
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
  });

  final AuthRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

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
  Future<void> signInWithCustomToken(String customToken) async {
    await firebaseAuth.signInWithCustomToken(customToken);
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
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
    final userCred = await firebaseAuth.signInWithCredential(credential);
    final appleDisplayName = [appleCredential.givenName, appleCredential.familyName]
        .where((e) => e != null && e.isNotEmpty)
        .join(' ');
    if (appleDisplayName.isNotEmpty &&
        (userCred.user?.displayName == null || userCred.user!.displayName!.isEmpty)) {
      await userCred.user?.updateDisplayName(appleDisplayName);
      await userCred.user?.reload();
    }
    return userCred;
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

  // Account
  @override
  Future<void> reauthWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final googleUser = await googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) throw Exception('Google sign-in failed');
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> reauthWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteAccount() async {
    final freshToken = await firebaseAuth.currentUser?.getIdToken(true);
    await remoteDataSource.deleteAccount(freshToken: freshToken);
    try {
      await firebaseAuth.currentUser?.delete();
    } catch (_) {}
    await firebaseAuth.signOut();
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      await googleSignIn.disconnect();
    } catch (_) {}
  }
}
