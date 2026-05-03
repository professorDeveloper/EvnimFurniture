import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/domain/model/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthBloc _authBloc;

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    if (_isLoggedIn) {
      _authBloc.add(const GetMeEvent());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _authBloc,
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final card = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final border = isDark ? AppColors.darkDivider : AppColors.divider;

    const radius = 14.0;
    const itemHeight = 56.0;

    final titleStyle = GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: text,
    );
    final subtitleStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: subText,
      height: 1.25,
    );
    final sectionStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: subText,
    );
    final rowStyle = GoogleFonts.dmSans(
      fontSize: 14.5,
      fontWeight: FontWeight.w400,
      color: text,
    );
    final trailingStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: subText,
    );

    Future<void> openLanguageSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          Widget langTile({
            required String flag,
            required String title,
            required bool selected,
            required VoidCallback onTap,
            required bool showDivider,
          }) {
            return Column(
              children: [
                InkWell(
                  onTap: onTap,
                  child: SizedBox(
                    height: itemHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              flag,
                              width: 28,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_rounded,
                                size: 20, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showDivider) Divider(height: 1, color: border),
              ],
            );
          }

          final langs = [
            (AppIcons.uzbek, AppTexts.langUzbek.tr(), 'uz'),
            (AppIcons.english, AppTexts.langEnglish.tr(), 'en'),
            (AppIcons.russian, AppTexts.langRussian.tr(), 'ru'),
          ];

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppTexts.selectLanguage.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: border),
                ...List.generate(langs.length, (i) {
                  final (flag, title, code) = langs[i];
                  return langTile(
                    flag: flag,
                    title: title,
                    selected: context.locale.languageCode == code,
                    showDivider: i < langs.length - 1,
                    onTap: () async {
                      await context.setLocale(Locale(code));
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }

    Widget profileItem({
      required IconData icon,
      required String title,
      String? trailingText,
      required VoidCallback onTap,
      required bool isLast,
      Color? iconColor,
      Color? titleColor,
    }) {
      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: Radius.zero,
                bottom: isLast ? const Radius.circular(radius) : Radius.zero,
              ),
              onTap: onTap,
              child: SizedBox(
                height: itemHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: iconColor ?? text),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: rowStyle.copyWith(color: titleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (trailingText != null) ...[
                        Text(trailingText, style: trailingStyle),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: subText),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isLast) Divider(height: 1, color: border),
        ],
      );
    }

    Widget welcomeHeader() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'welcome_to'.tr(args: [AppTexts.appName.tr()]),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: text,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'need_login_to_continue'.tr(),
                textAlign: TextAlign.center,
                style: subtitleStyle,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.pushNamed(context, Pages.login);
                    },
                    child: Center(
                      child: Text(
                        'login'.tr(),
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    Widget userHeader(UserModel user) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.grey100,
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.grey200,
                    width: 1.5,
                  ),
                ),
                child: user.picture != null && user.picture!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.picture!,
                          memCacheWidth: 200,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: subText,
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: subText,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: subText,
                      ),
              ),
              const SizedBox(width: 14),
              // Name & contact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.displayContact.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.displayContact,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: subText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    Pages.editProfile,
                    arguments: user,
                  );
                  if (result != null && context.mounted) {
                    context.read<AuthBloc>().add(const GetMeEvent());
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: subText,
                  ),
                ),
              ),
            ],
          ),
        );

    void _showLogoutDialog(BuildContext ctx) {
      showDialog(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'logoutConfirm'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          content: Text(
            'logoutConfirmDesc'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: subText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: subText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                ctx.read<AuthBloc>().add(const LogoutEvent());
              },
              child: Text(
                'logout'.tr(),
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


    final themeTrailing = themeController.mode == ThemeMode.dark
        ? 'theme_dark'.tr()
        : 'theme_light'.tr();

    final groups = [
      {
        'title': 'settings'.tr(),
        'items': [
          {
            'icon': Icons.language_outlined,
            'title': 'language'.tr(),
            'trailing': null,
            'onTap': openLanguageSheet,
          },
          {
            'icon': Icons.dark_mode_outlined,
            'title': 'theme'.tr(),
            'trailing': themeTrailing,
            'onTap': () => themeController.toggle(),
          },
        ],
      },
      {
        'title': 'info'.tr(),
        'items': [
          {
            'icon': Icons.help_outline_rounded,
            'title': 'help'.tr(),
            'trailing': null,
            'onTap': () => Navigator.pushNamed(context, Pages.help),
          },
          {
            'icon': Icons.support_agent_outlined,
            'title': 'contact_support'.tr(),
            'trailing': null,
            'onTap': () => launchUrl(
              Uri.parse('https://t.me/evim_uzb'),
              mode: LaunchMode.externalApplication,
            ),
          },
          {
            'icon': Icons.privacy_tip_outlined,
            'title': 'legal_info'.tr(),
            'trailing': null,
            'onTap': () => Navigator.pushNamed(context, Pages.legalInfo),
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(AppTexts.navProfile.tr(), style: titleStyle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          displacement: 20,
          onRefresh: () async {
            final isLoggedIn =
                FirebaseAuth.instance.currentUser != null;
            if (isLoggedIn) {
              context.read<AuthBloc>().add(const GetMeEvent());
              await context
                  .read<AuthBloc>()
                  .stream
                  .firstWhere((s) =>
                      s is UserLoaded || s is UserError);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // User header or welcome
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return userHeader(state.user);
                    }
                    if (state is UserLoading) {
                      return _UserHeaderShimmer(
                          isDark: isDark, border: border, subText: subText);
                    }
                    return welcomeHeader();
                  },
                ),
              const SizedBox(height: 20),

              for (final g in groups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(g['title']! as String, style: sectionStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(color: border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Column(
                        children: [
                          for (int i = 0;
                              i < (g['items']! as List).length;
                              i++)
                            profileItem(
                              icon: ((g['items']! as List)[i]['icon']
                                  as IconData),
                              title: ((g['items']! as List)[i]['title']
                                  as String),
                              trailingText: ((g['items']! as List)[i]
                                  ['trailing'] as String?),
                              onTap: ((g['items']! as List)[i]['onTap']
                                  as VoidCallback),
                              isLast: i == (g['items']! as List).length - 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Logout + Delete Account buttons (only when logged in)
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is LoggedOut) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Pages.home,
                      (_) => false,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UserLoaded) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(radius),
                              border: Border.all(color: border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: profileItem(
                                icon: Icons.logout_rounded,
                                title: 'logout'.tr(),
                                onTap: () => _showLogoutDialog(context),
                                isLast: true,
                                iconColor: AppColors.error,
                                titleColor: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: card,
                              borderRadius: BorderRadius.circular(radius),
                              border: Border.all(color: border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(radius),
                              child: profileItem(
                                icon: Icons.person_remove_outlined,
                                title: AppTexts.deleteAccount.tr(),
                                onTap: () => Navigator.pushNamed(
                                    context, Pages.deleteAccount,
                                    arguments: state.user),
                                isLast: true,
                                iconColor: AppColors.error,
                                titleColor: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
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
    );
  }
}

class _UserHeaderShimmer extends StatefulWidget {
  const _UserHeaderShimmer({
    required this.isDark,
    required this.border,
    required this.subText,
  });

  final bool isDark;
  final Color border;
  final Color subText;

  @override
  State<_UserHeaderShimmer> createState() => _UserHeaderShimmerState();
}

class _UserHeaderShimmerState extends State<_UserHeaderShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmer = widget.isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.grey200;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Avatar shimmer
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shimmer.withValues(alpha: _anim.value),
                ),
              ),
              const SizedBox(width: 14),
              // Name + contact shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: shimmer.withValues(alpha: _anim.value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: shimmer.withValues(alpha: _anim.value * 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
