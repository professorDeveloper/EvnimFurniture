import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/model/login_response.dart';
import '../../domain/model/otp_response.dart';
import '../../domain/model/user_model.dart';

abstract class AuthRemoteDataSource {
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

  // Profile
  Future<UserModel> completeProfile({
    required String name,
    required String userType,
    String? picturePath,
  });
  Future<UserModel> editProfile({String? name, String? picturePath, String? userType});

  // Social login
  Future<LoginResponse> socialLogin();

  // User
  Future<UserModel> getMe();

  // Account
  Future<void> deleteAccount({String? freshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  // Phone OTP
  @override
  Future<SendOtpResponse> sendOtp({required String phone}) async {
    final res = await dioClient.dio.post(
      '/api/auth/phone/send-otp',
      data: {'phone': phone},
    );
    return SendOtpResponse.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final res = await dioClient.dio.post(
      '/api/auth/phone/verify-otp',
      data: {'phone': phone, 'otp': code},
    );
    return VerifyOtpResponse.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<SendOtpResponse> resendOtp({required String phone}) async {
    final res = await dioClient.dio.post(
      '/api/auth/phone/resend-otp',
      data: {'phone': phone},
    );
    return SendOtpResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // Email OTP
  @override
  Future<SendOtpResponse> sendEmailOtp({required String email}) async {
    final res = await dioClient.dio.post(
      '/api/auth/email/send-otp',
      data: {'email': email},
    );
    return SendOtpResponse.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<VerifyOtpResponse> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final res = await dioClient.dio.post(
      '/api/auth/email/verify-otp',
      data: {'email': email, 'otp': code},
    );
    return VerifyOtpResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // Profile
  @override
  Future<UserModel> completeProfile({
    required String name,
    required String userType,
    String? picturePath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'userType': userType,
      if (picturePath != null)
        'picture': await MultipartFile.fromFile(picturePath),
    });
    final res = await dioClient.dio.post(
      '/api/auth/complete-profile',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> editProfile({String? name, String? picturePath, String? userType}) async {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (userType != null) map['userType'] = userType;
    if (picturePath != null) {
      map['picture'] = await MultipartFile.fromFile(picturePath);
    }
    final formData = FormData.fromMap(map);
    final res = await dioClient.dio.put(
      '/api/auth/edit-profile',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  // Social login
  @override
  Future<LoginResponse> socialLogin() async {
    final res = await dioClient.dio.post('/api/auth/login');
    return LoginResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // User
  @override
  Future<UserModel> getMe() async {
    final res = await dioClient.dio.get('/api/auth/me');
    final data = res.data as Map<String, dynamic>;
    return UserModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  // Account
  @override
  Future<void> deleteAccount({String? freshToken}) async {
    await dioClient.dio.delete(
      '/api/auth/account',
      data: {'confirmation': 'DELETE'},
      options: freshToken != null
          ? Options(headers: {'Authorization': 'Bearer $freshToken'})
          : null,
    );
  }
}
