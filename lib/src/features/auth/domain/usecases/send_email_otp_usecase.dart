import '../model/otp_response.dart';
import '../repositories/auth_repository.dart';

class SendEmailOtpUseCase {
  const SendEmailOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<SendOtpResponse> call({required String email}) =>
      _repository.sendEmailOtp(email: email);
}
