import '../model/otp_response.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<SendOtpResponse> call({required String phone}) =>
      _repository.resendOtp(phone: phone);
}
