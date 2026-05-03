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

import '../../domain/model/user_model.dart';
import '../bloc/auth_bloc.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  void _onDeletePressed() {
    final cs = Theme.of(context).colorScheme;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppTexts.deleteAccountConfirm.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        content: Text(
          AppTexts.deleteAccountConfirmDesc.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: subText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startDeleteFlow();
            },
            child: Text(
              AppTexts.deleteAccountBtn.tr(),
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startDeleteFlow() {
    final provider = widget.user.provider ?? '';
    switch (provider) {
      case 'google':
      case 'apple':
        _authBloc.add(DeleteAccountEvent(provider: provider));
        break;
      case 'email':
        _authBloc.add(DeleteSendOtpEvent(email: widget.user.email));
        break;
      case 'phone':
      default:
        _authBloc.add(DeleteSendOtpEvent(phone: widget.user.phone));
        break;
    }
  }

  void _showOtpBottomSheet() {
    final provider = widget.user.provider ?? '';
    final isEmail = provider == 'email';
    final destination = isEmail
        ? (widget.user.email ?? '')
        : (widget.user.phone ?? '');
    if (destination.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: _authBloc,
        child: _OtpBottomSheet(
          isEmail: isEmail,
          destination: destination,
          authBloc: _authBloc,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final card = isDark ? AppColors.darkSurface : const Color(0xFFF8F8F8);
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final border = isDark ? AppColors.darkDivider : AppColors.divider;

    final items = [
      (Icons.person_outline_rounded, AppTexts.deleteAccountItem1.tr()),
      (Icons.favorite_border_rounded, AppTexts.deleteAccountItem2.tr()),
      (Icons.star_border_rounded, AppTexts.deleteAccountItem3.tr()),
      (Icons.history_rounded, AppTexts.deleteAccountItem4.tr()),
      (Icons.notifications_none_rounded, AppTexts.deleteAccountItem5.tr()),
    ];

    return BlocProvider(
      create: (_) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AccountDeleted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Pages.home,
              (_) => false,
            );
          } else if (state is DeleteOtpSent) {
            _showOtpBottomSheet();
          } else if (state is AccountDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: text,
              ),
            ),
            title: Text(
              AppTexts.deleteAccount.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppTexts.deleteAccountTitle.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: text,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppTexts.deleteAccountSubtitle.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: subText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: List.generate(items.length, (i) {
                        final (icon, label) = items[i];
                        final isLast = i == items.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 20,
                                    color: AppColors.error.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) Divider(height: 1, color: border),
                          ],
                        );
                      }),
                    ),
                  ),

                  const Spacer(),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AccountDeleting;
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onDeletePressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor:
                                    AppColors.error.withValues(alpha: 0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : Text(
                                      AppTexts.deleteAccountBtn.tr(),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'cancel'.tr(),
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isLoading ? subText : cs.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
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

class _OtpBottomSheet extends StatefulWidget {
  const _OtpBottomSheet({
    required this.isEmail,
    required this.destination,
    required this.authBloc,
  });

  final bool isEmail;
  final String destination;
  final AuthBloc authBloc;

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  static const int _codeLength = 5;
  static const int _timerSeconds = 60;

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  int _countdown = _timerSeconds;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
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

  void _onCompleted(String code) {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    if (widget.isEmail) {
      widget.authBloc.add(
        DeleteVerifyOtpEvent(code: code, email: widget.destination),
      );
    } else {
      widget.authBloc.add(
        DeleteVerifyOtpEvent(code: code, phone: widget.destination),
      );
    }
  }

  String get _maskedDestination {
    if (!widget.isEmail) {
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
    final bg = isDark ? AppColors.darkSurface : AppColors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;

    final pinWidth = (MediaQuery.of(context).size.width - 48 - 32) / 5;
    final defaultPinTheme = PinTheme(
      width: pinWidth.clamp(48, 64),
      height: pinWidth.clamp(48, 64),
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
        border: Border.all(color: AppColors.error, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AccountDeleteError) {
          setState(() => _isVerifying = false);
          _pinController.clear();
          _focusNode.requestFocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: subText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Icon(
            Icons.shield_outlined,
            size: 32,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),

          Text(
            AppTexts.deleteReauthOtp.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 8),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: subText,
                height: 1.5,
              ),
              children: [
                TextSpan(text: '${AppTexts.authOtpSubtitle.tr()} '),
                TextSpan(
                  text: _maskedDestination,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: text,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          if (_isVerifying)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.error,
                ),
              ),
            )
          else
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

          const SizedBox(height: 20),

          if (_countdown > 0)
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: subText,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(text: '${AppTexts.authResendIn.tr()} '),
                  TextSpan(
                    text: '0:${_countdown.toString().padLeft(2, '0')}',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Text(
            AppTexts.authOtpSecure.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: subText.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      ),
    );
  }
}
