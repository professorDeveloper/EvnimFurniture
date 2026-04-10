import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_icons.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late AuthBloc _authBloc;

  String _countryCode = '+998';
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _phoneFocus.addListener(() {
      setState(() => _isFocused = _phoneFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _animController.dispose();
    _authBloc.close();
    super.dispose();
  }

  bool get _isPhoneValid {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9;
  }

  String get _fullPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return '${_countryCode.replaceAll('+', '')}$digits';
  }

  void _onContinuePhone() {
    if (!_isPhoneValid) return;
    _authBloc.add(SendOtpEvent(phone: _fullPhone));
  }

  void _onContinueGoogle() {
    _authBloc.add(const SocialLoginEvent(provider: 'google'));
  }

  void _onContinueApple() {
    _authBloc.add(const SocialLoginEvent(provider: 'apple'));
  }

  void _onContinueEmail() {
    _showEmailBottomSheet();
  }

  void _showEmailBottomSheet() {
    final emailController = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppTexts.authEnterEmail.tr(),
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : cs.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.authEmailDesc.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: GoogleFonts.dmSans(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'example@mail.com',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.contains('@') && email.contains('.')) {
                        Navigator.pop(ctx);
                        _authBloc.add(SendEmailOtpEvent(email: email));
                      }
                    },
                    child: Text(AppTexts.btnContinue.tr()),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isIOS = Platform.isIOS;
    final isSmall = size.height < 700;

    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSent) {
            final isEmail = state.email != null;
            Navigator.pushNamed(
              context,
              Pages.otp,
              arguments: {
                'type': isEmail ? 'email' : 'phone',
                'destination': isEmail ? state.email! : _fullPhone,
              },
            );
          } else if (state is OtpSendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          } else if (state is SocialLoginSuccess) {
            if (state.isNewUser && !state.user.profileCompleted) {
              Navigator.pushNamed(context, Pages.completeProfile,
                  arguments: state.user.name);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Pages.home,
                (_) => false,
              );
            }
          } else if (state is SocialLoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Top section: logo + title + input + button
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Logo
                            Hero(
                              tag: 'app_logo',
                              child: SvgPicture.asset(
                                AppIcons.appIcon,
                                width: size.width * (isSmall ? 0.28 : 0.4),
                                height: size.width * (isSmall ? 0.28 : 0.4),
                                colorFilter: isDark
                                    ? const ColorFilter.mode(
                                        AppColors.white, BlendMode.srcIn)
                                    : null,
                              ),
                            ),
                            SizedBox(height: isSmall ? 16 : 24),

                            // Title
                            Text(
                              AppTexts.authLoginTitle.tr(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: isSmall ? 20 : 24,
                                fontWeight: FontWeight.w800,
                                color:
                                    isDark ? AppColors.white : cs.secondary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: isSmall ? 4 : 8),
                            Text(
                              AppTexts.authLoginSubtitle.tr(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: isSmall ? 12 : 14,
                                color: cs.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),

                            SizedBox(height: isSmall ? 20 : 32),

                            // Phone input
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.grey50,
                                border: Border.all(
                                  color: _isFocused
                                      ? cs.primary
                                      : (isDark
                                          ? AppColors.darkDivider
                                          : AppColors.grey200),
                                  width: _isFocused ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: isDark
                                                ? AppColors.darkDivider
                                                : AppColors.grey200,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('\u{1F1FA}\u{1F1FF}',
                                              style: TextStyle(fontSize: 18)),
                                          const SizedBox(width: 4),
                                          Text(
                                            _countryCode,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          Icon(
                                              Icons
                                                  .keyboard_arrow_down_rounded,
                                              size: 16,
                                              color: cs.onSurfaceVariant),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      keyboardType: TextInputType.phone,
                                      onChanged: (_) => setState(() {}),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(12),
                                        _PhoneFormatter(),
                                      ],
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: cs.onSurface,
                                        letterSpacing: 0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '90 123 45 67',
                                        hintStyle: GoogleFonts.dmSans(
                                          fontSize: 15,
                                          color: cs.onSurfaceVariant
                                              .withOpacity(0.4),
                                          letterSpacing: 0.5,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                        filled: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Continue button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is OtpSending;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: (_isPhoneValid && !isLoading)
                                        ? _onContinuePhone
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      foregroundColor: AppColors.white,
                                      disabledBackgroundColor: isDark
                                          ? cs.primary.withOpacity(0.25)
                                          : AppColors.primary200,
                                      disabledForegroundColor:
                                          AppColors.white.withOpacity(0.7),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
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
                                            AppTexts.btnContinue.tr(),
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmall ? 16 : 32),

                      // Bottom section: social buttons
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        Divider(color: cs.outlineVariant)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    AppTexts.authOr.tr(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child:
                                        Divider(color: cs.outlineVariant)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isSocialLoading =
                                    state is SocialLoginLoading;
                                if (isSocialLoading) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    if (isIOS) ...[
                                      _SocialButton(
                                        onTap: _onContinueApple,
                                        svgPath: AppIcons.apple,
                                        label:
                                            AppTexts.authContinueApple.tr(),
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 8),
                                      _SocialButton(
                                        onTap: _onContinueEmail,
                                        icon: Icons.email_outlined,
                                        label:
                                            AppTexts.authContinueEmail.tr(),
                                        isDark: isDark,
                                      ),
                                    ] else ...[
                                      _SocialButton(
                                        onTap: _onContinueGoogle,
                                        svgPath: AppIcons.google,
                                        label:
                                            AppTexts.authContinueGoogle.tr(),
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 8),
                                      _SocialButton(
                                        onTap: _onContinueEmail,
                                        icon: Icons.email_outlined,
                                        label:
                                            AppTexts.authContinueEmail.tr(),
                                        isDark: isDark,
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // Terms
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                AppTexts.authTerms.tr(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color:
                                      cs.onSurfaceVariant.withOpacity(0.6),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.label,
    required this.isDark,
    this.icon,
    this.svgPath,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final String label;
  final bool isDark;
  final String? svgPath;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.grey300,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgPath != null)
              SvgPicture.asset(svgPath!, width: 18, height: 18)
            else if (icon != null)
              Icon(icon, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
