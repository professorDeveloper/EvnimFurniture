import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTexts.favouritesTitle.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated heart icon
                Opacity(
                  opacity: _iconFade.value,
                  child: Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.12)
                            : AppColors.secondary50,
                      ),
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        size: 40,
                        color: isDark
                            ? AppColors.secondary300
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title + description
                FractionalTranslation(
                  translation: _textSlide.value,
                  child: Opacity(
                    opacity: _textFade.value,
                    child: Column(
                      children: [
                        Text(
                          AppTexts.favouritesEmpty.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTexts.favouritesEmptyDesc.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.grey400
                                : AppColors.grey500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
