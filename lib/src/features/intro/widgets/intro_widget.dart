import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class S4FullImage extends StatelessWidget {
  const S4FullImage({super.key, required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (_, v, __) => Opacity(opacity: v, child: child),
        );
      },
      errorBuilder: (_, __, ___) =>
      const ColoredBox(color: AppColors.secondary100),
    );
  }
}

class S4PageIndicator extends StatelessWidget {
  const S4PageIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: active ? AppColors.secondary : AppColors.secondary100,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class S4Title extends StatelessWidget {
  const S4Title({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fs = w < 360 ? 22.0 : (w < 400 ? 24.0 : 26.0);

    return Text(
      title,
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: fs,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
        height: 1.25,
        letterSpacing: -0.3,
      ),
    );
  }
}

class S4Subtitle extends StatelessWidget {
  const S4Subtitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: w < 360 ? 13.0 : 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.secondary300,
        height: 1.65,
      ),
    );
  }
}

class S4BottomNav extends StatelessWidget {
  const S4BottomNav({
    super.key,
    required this.count,
    required this.current,
    required this.label,
    required this.skipLabel,
    required this.isLast,
    required this.onTap,
    required this.onSkip,
  });

  final int count;
  final int current;
  final String label;
  final String skipLabel;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onSkip,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              skipLabel,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary200,
              ),
            ),
          ),
        ),
        S4PageIndicator(count: count, current: current),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}