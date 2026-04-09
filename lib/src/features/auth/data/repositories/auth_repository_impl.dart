import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/model/otp_response.dart';
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
}
