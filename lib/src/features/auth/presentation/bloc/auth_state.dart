part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

// Send OTP states
class OtpSending extends AuthState {
  const OtpSending();
}

class OtpSent extends AuthState {
  const OtpSent({required this.phone, required this.message});
  final String phone;
  final String message;
}

class OtpSendError extends AuthState {
  const OtpSendError({required this.message});
  final String message;
}

// Verify OTP states
class OtpVerifying extends AuthState {
  const OtpVerifying();
}

class OtpVerified extends AuthState {
  const OtpVerified({required this.isNewUser});
  final bool isNewUser;
}

class OtpVerifyError extends AuthState {
  const OtpVerifyError({required this.message});
  final String message;
}

// Resend OTP states
class OtpResending extends AuthState {
  const OtpResending();
}

class OtpResent extends AuthState {
  const OtpResent({required this.message});
  final String message;
}

class OtpResendError extends AuthState {
  const OtpResendError({required this.message});
  final String message;
}
