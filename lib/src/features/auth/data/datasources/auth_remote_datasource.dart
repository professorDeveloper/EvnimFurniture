import '../../../../core/network/dio_client.dart';
import '../../domain/model/otp_response.dart';

abstract class AuthRemoteDataSource {
  Future<SendOtpResponse> sendOtp({required String phone});
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
  });
  Future<SendOtpResponse> resendOtp({required String phone});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

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
}
