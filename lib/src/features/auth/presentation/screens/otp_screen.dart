import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../bloc/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.type,
    required this.destination,
  });

  final String type;
  final String destination;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _codeLength = 5;
  static const int _maxResend = 5;
  static const int _timerSeconds = 60;

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  late AuthBloc _authBloc;

  int _resendCount = 0;
  int _countdown = _timerSeconds;
  Timer? _timer;

  bool get _isPhone => widget.type == 'phone';
  bool get _canResend =>
      _isPhone && _resendCount < _maxResend && _countdown == 0;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = _timerSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onResend() {
    if (!_canResend) return;
    setState(() => _resendCount++);
    _authBloc.add(ResendOtpEvent(phone: widget.destination));
    _startCountdown();
    _pinController.clear();
    _focusNode.requestFocus();
  }

  void _onCompleted(String code) {
    if (_isPhone) {
      _authBloc.add(VerifyOtpEvent(phone: widget.destination, code: code));
    } else {
      _authBloc.add(VerifyEmailOtpEvent(email: widget.destination, code: code));
    }
  }

  String get _maskedDestination {
    if (_isPhone) {
      final d = widget.destination;
      if (d.length > 6) {
        return '+${d.substring(0, 3)} **** ** ${d.substring(d.length - 2)}';
      }
      return d;
    }
    final parts = widget.destination.split('@');
    if (parts.length == 2 && parts[0].length > 2) {
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    }
    return widget.destination;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.grey200,
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: cs.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: (isDark ? AppColors.secondary200 : AppColors.secondary)
              .withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    );

    return BlocProvider(
      create: (_) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            if (state.isNewUser) {
              Navigator.pushNamed(context, Pages.completeProfile);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Pages.home,
                (_) => false,
              );
            }
          } else if (state is OtpVerifyError) {
            _pinController.clear();
            _focusNode.requestFocus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          } else if (state is OtpResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is OtpResendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: cs.onSurface,
              ),
            ),
            centerTitle: true,
            title: Text(
              AppTexts.authOtpTitle.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                        children: [
                          TextSpan(
                              text: '${AppTexts.authOtpSubtitle.tr()} '),
                          TextSpan(
                            text: _maskedDestination,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Pinput(
                    length: _codeLength,
                    controller: _pinController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    keyboardType: TextInputType.number,
                    onCompleted: _onCompleted,
                    closeKeyboardWhenCompleted: false,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),

                  const SizedBox(height: 24),

                  if (_isPhone)
                    Column(
                      children: [
                        if (_countdown > 0) ...[
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                    text:
                                        '${AppTexts.authResendIn.tr()} '),
                                TextSpan(
                                  text:
                                      '0:${_countdown.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_resendCount < _maxResend) ...[
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isResending = state is OtpResending;
                              return TextButton(
                                onPressed:
                                    isResending ? null : _onResend,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: isResending
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.primary,
                                        ),
                                      )
                                    : Text(
                                        AppTexts.authResendCode.tr(),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: cs.primary,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                        if (_resendCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${AppTexts.authAttemptsLeft.tr()}: ${_maxResend - _resendCount}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color:
                                    cs.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.secondary800.withValues(alpha: 0.3)
                            : AppColors.secondary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.secondary200
                                  : cs.secondary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppTexts.authCheckEmail.tr(),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.secondary200
                                    : cs.secondary,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    AppTexts.authOtpSecure.tr(),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                    ),
                  ),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is OtpVerifying) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cs.primary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
