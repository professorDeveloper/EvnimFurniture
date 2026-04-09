import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/theme/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ProfileBody();
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({super.key});

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
    final welcomeStyle = GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: text,
      height: 1.15,
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
    }) {
      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: isLast ? Radius.zero : Radius.zero,
                bottom: isLast ? const Radius.circular(radius) : Radius.zero,
              ),
              onTap: onTap,
              child: SizedBox(
                height: itemHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: text),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: rowStyle,
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
                style: welcomeStyle,
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
            'onTap': () {},
          },
          {
            'icon': Icons.star_outline_rounded,
            'title': 'rate_us'.tr(),
            'trailing': null,
            'onTap': () {},
          },
          {
            'icon': Icons.support_agent_outlined,
            'title': 'contact_support'.tr(),
            'trailing': null,
            'onTap': () {},
          },
          {
            'icon': Icons.privacy_tip_outlined,
            'title': 'legal_info'.tr(),
            'trailing': null,
            'onTap': () {},
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(AppTexts.navProfile.tr(), style: titleStyle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              welcomeHeader(),
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
                          for (int i = 0; i < (g['items']! as List).length; i++)
                            profileItem(
                              icon: ((g['items']! as List)[i]['icon']
                                  as IconData),
                              title:
                                  ((g['items']! as List)[i]['title'] as String),
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
            ],
          ),
        ),
      ),
    );
  }
}
