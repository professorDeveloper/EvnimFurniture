part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

// Phone OTP
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

// Email OTP
class SendEmailOtpEvent extends AuthEvent {
  const SendEmailOtpEvent({required this.email});
  final String email;
}

class VerifyEmailOtpEvent extends AuthEvent {
  const VerifyEmailOtpEvent({required this.email, required this.code});
  final String email;
  final String code;
}

// Social login
class SocialLoginEvent extends AuthEvent {
  const SocialLoginEvent({required this.provider});
  final String provider; // 'google' or 'apple'
}

// User
class GetMeEvent extends AuthEvent {
  const GetMeEvent();
}

// Profile
class CompleteProfileEvent extends AuthEvent {
  const CompleteProfileEvent({
    required this.name,
    required this.userType,
    this.picturePath,
  });
  final String name;
  final String userType;
  final String? picturePath;
}

class EditProfileEvent extends AuthEvent {
  const EditProfileEvent({this.name, this.picturePath});
  final String? name;
  final String? picturePath;
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
