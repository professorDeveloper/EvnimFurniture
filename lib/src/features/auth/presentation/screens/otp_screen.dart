import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

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
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _codeLength) {
      _verifyCode(code);
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyCode(String code) {
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
            // Clear OTP fields on error
            for (final c in _controllers) {
              c.clear();
            }
            _focusNodes[0].requestFocus();
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

                  // Subtitle + destination
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

                  // OTP Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_codeLength, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 5,
                              right: i == _codeLength - 1 ? 0 : 5,
                            ),
                            child: _OtpField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              isDark: isDark,
                              onChanged: (v) => _onCodeChanged(i, v),
                              onKeyEvent: (e) => _onKeyDown(i, e),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timer + Resend
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
                                    cs.onSurfaceVariant.withOpacity(0.6),
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
                            ? AppColors.secondary800.withOpacity(0.3)
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

                  // Security note
                  Text(
                    AppTexts.authOtpSecure.tr(),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: cs.onSurfaceVariant.withOpacity(0.45),
                    ),
                  ),

                  // Verify loading
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

class _OtpField extends StatefulWidget {
  const _OtpField({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  @override
  State<_OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<_OtpField> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasValue = widget.controller.text.isNotEmpty;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color:
              widget.isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasFocus
                ? cs.primary
                : hasValue
                    ? (widget.isDark
                            ? AppColors.secondary200
                            : AppColors.secondary)
                        .withOpacity(0.4)
                    : (widget.isDark
                        ? AppColors.darkDivider
                        : AppColors.grey200),
            width: _hasFocus ? 2 : 1.5,
          ),
        ),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ),
      ),
    );
  }
}
