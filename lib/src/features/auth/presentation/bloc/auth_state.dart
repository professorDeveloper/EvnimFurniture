part of 'auth_bloc.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

// Send OTP states (phone & email)
class OtpSending extends AuthState {
  const OtpSending();
}

class OtpSent extends AuthState {
  const OtpSent({this.phone, this.email, required this.message});
  final String? phone;
  final String? email;
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

// Social login states
class SocialLoginLoading extends AuthState {
  const SocialLoginLoading();
}

class SocialLoginSuccess extends AuthState {
  const SocialLoginSuccess({
    required this.isNewUser,
    required this.user,
  });
  final bool isNewUser;
  final UserModel user;
}

class SocialLoginError extends AuthState {
  const SocialLoginError({required this.message});
  final String message;
}

// User states
class UserLoading extends AuthState {
  const UserLoading();
}

class UserLoaded extends AuthState {
  const UserLoaded({required this.user});
  final UserModel user;
}

class UserError extends AuthState {
  const UserError({required this.message});
  final String message;
}

// Profile completion/edit
class ProfileSaving extends AuthState {
  const ProfileSaving();
}

class ProfileSaved extends AuthState {
  const ProfileSaved({required this.user});
  final UserModel user;
}

class ProfileSaveError extends AuthState {
  const ProfileSaveError({required this.message});
  final String message;
}

class LoggedOut extends AuthState {
  const LoggedOut();
}
