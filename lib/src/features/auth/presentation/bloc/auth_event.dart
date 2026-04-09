part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class SendOtpEvent extends AuthEvent {
  const SendOtpEvent({required this.phone});
  final String phone;
}

class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent({required this.phone, required this.code});
  final String phone;
  final String code;
}

class ResendOtpEvent extends AuthEvent {
  const ResendOtpEvent({required this.phone});
  final String phone;
}
