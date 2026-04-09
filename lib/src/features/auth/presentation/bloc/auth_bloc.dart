import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';

import '../../domain/model/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/send_email_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/complete_profile_usecase.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required SendEmailOtpUseCase sendEmailOtpUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required GetMeUseCase getMeUseCase,
    required CompleteProfileUseCase completeProfileUseCase,
    required EditProfileUseCase editProfileUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required AuthRepository authRepository,
  })  : _sendOtpUseCase = sendOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        _sendEmailOtpUseCase = sendEmailOtpUseCase,
        _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
        _getMeUseCase = getMeUseCase,
        _completeProfileUseCase = completeProfileUseCase,
        _editProfileUseCase = editProfileUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<SendEmailOtpEvent>(_onSendEmailOtp);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<SocialLoginEvent>(_onSocialLogin);
    on<GetMeEvent>(_onGetMe);
    on<CompleteProfileEvent>(_onCompleteProfile);
    on<EditProfileEvent>(_onEditProfile);
    on<LogoutEvent>(_onLogout);
  }

  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final SendEmailOtpUseCase _sendEmailOtpUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final GetMeUseCase _getMeUseCase;
  final CompleteProfileUseCase _completeProfileUseCase;
  final EditProfileUseCase _editProfileUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final AuthRepository _authRepository;

  // Phone OTP
  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const OtpSending());
    try {
      final response = await _sendOtpUseCase(phone: event.phone);
      emit(OtpSent(phone: response.phone, message: response.message));
    } catch (e) {
      emit(OtpSendError(message: _parseError(e)));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const OtpVerifying());
    try {
      final isNewUser = await _verifyOtpUseCase(
        phone: event.phone,
        code: event.code,
      );
      emit(OtpVerified(isNewUser: isNewUser));
    } catch (e) {
      emit(OtpVerifyError(message: _parseError(e)));
    }
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const OtpResending());
    try {
      final response = await _resendOtpUseCase(phone: event.phone);
      emit(OtpResent(message: response.message));
    } catch (e) {
      emit(OtpResendError(message: _parseError(e)));
    }
  }

  // Email OTP
  Future<void> _onSendEmailOtp(
    SendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const OtpSending());
    try {
      final response = await _sendEmailOtpUseCase(email: event.email);
      emit(OtpSent(email: response.email, message: response.message));
    } catch (e) {
      emit(OtpSendError(message: _parseError(e)));
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const OtpVerifying());
    try {
      final isNewUser = await _verifyEmailOtpUseCase(
        email: event.email,
        code: event.code,
      );
      emit(OtpVerified(isNewUser: isNewUser));
    } catch (e) {
      emit(OtpVerifyError(message: _parseError(e)));
    }
  }

  // Social login
  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const SocialLoginLoading());
    try {
      final response = await _socialLoginUseCase(provider: event.provider);
      emit(SocialLoginSuccess(
        isNewUser: response.isNewUser,
        user: response.user,
      ));
    } catch (e) {
      final msg = e.toString();
      // Don't show error for user cancellation
      if (msg.contains('cancelled') || msg.contains('canceled')) {
        emit(const AuthInitial());
        return;
      }
      emit(SocialLoginError(message: _parseError(e)));
    }
  }

  // User
  Future<void> _onGetMe(
    GetMeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await _getMeUseCase();
      emit(UserLoaded(user: user));
    } catch (e) {
      emit(UserError(message: _parseError(e)));
    }
  }

  // Profile
  Future<void> _onCompleteProfile(
    CompleteProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ProfileSaving());
    try {
      final user = await _completeProfileUseCase(
        name: event.name,
        userType: event.userType,
        picturePath: event.picturePath,
      );
      emit(ProfileSaved(user: user));
    } catch (e) {
      emit(ProfileSaveError(message: _parseError(e)));
    }
  }

  Future<void> _onEditProfile(
    EditProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ProfileSaving());
    try {
      final user = await _editProfileUseCase(
        name: event.name,
        picturePath: event.picturePath,
        userType: event.userType,
      );
      emit(ProfileSaved(user: user));
    } catch (e) {
      emit(ProfileSaveError(message: _parseError(e)));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await NotificationService.instance.unregisterToken();
    await _authRepository.logout();
    emit(const LoggedOut());
  }

  String _parseError(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    return e.toString();
  }
}
