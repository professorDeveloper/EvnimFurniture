import '../model/otp_response.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  const SendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<SendOtpResponse> call({required String phone}) =>
      _repository.sendOtp(phone: phone);
}
