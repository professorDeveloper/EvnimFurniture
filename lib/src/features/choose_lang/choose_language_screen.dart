import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_icons.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen>
    with SingleTickerProviderStateMixin {
  Locale? _selected;
  bool _inited = false;

  late AnimationController _btnController;
  late Animation<Offset> _btnSlide;
  late Animation<double> _btnFade;

  static const List<_LangOption> _options = <_LangOption>[
    _LangOption(locale: Locale('uz'), titleKey: AppTexts.langUzbek, iconPath: AppIcons.uzbek),
    _LangOption(locale: Locale('ru'), titleKey: AppTexts.langRussian, iconPath: AppIcons.russian),
    _LangOption(locale: Locale('en'), titleKey: AppTexts.langEnglish, iconPath: AppIcons.english),
  ];

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeOutCubic));
    _btnFade = CurvedAnimation(parent: _btnController, curve: Curves.easeOut);
    _btnController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _selected = context.locale;
      _inited = true;
    }
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _pick(Locale locale) async {
    setState(() => _selected = locale);
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final Locale current = _selected ?? context.locale;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Text(
                AppTexts.chooseLanguageTitle.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.secondary,
                  letterSpacing: -0.4,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppTexts.chooseLanguageDesc.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: cs.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              for (final _LangOption opt in _options) ...<Widget>[
                _LanguageTile(
                  title: opt.titleKey.tr(),
                  iconPath: opt.iconPath,
                  selected: opt.locale.languageCode == current.languageCode,
                  isDark: isDark,
                  onTap: () => _pick(opt.locale),
                ),
                const SizedBox(height: 8),
              ],
              const Spacer(),
              SlideTransition(
                position: _btnSlide,
                child: FadeTransition(
                  opacity: _btnFade,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.secondary,
                        foregroundColor: cs.onSecondary,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pushNamed(context, Pages.intro),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(AppTexts.btnContinue.tr()),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.iconPath,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String iconPath;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final Color selectedBg = isDark
        ? AppColors.secondary600.withOpacity(0.3)
        : AppColors.secondary50;
    final Color selectedBorder = cs.secondary;
    final Color unselectedBorder = cs.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected ? selectedBg : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? selectedBorder : unselectedBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: Image.asset(
                    iconPath,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                _SelectDot(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? cs.secondary : Colors.transparent,
        border: Border.all(
          color: selected ? cs.secondary : cs.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 13, color: cs.onSecondary)
          : null,
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.locale,
    required this.titleKey,
    required this.iconPath,
  });

  final Locale locale;
  final String titleKey;
  final String iconPath;
}