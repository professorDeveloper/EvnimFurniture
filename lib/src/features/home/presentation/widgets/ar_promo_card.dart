import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class ArPromoCard extends StatefulWidget {
  const ArPromoCard({super.key, required this.isDark});

  final bool isDark;

  @override
  State<ArPromoCard> createState() => _ArPromoCardState();
}

class _ArPromoCardState extends State<ArPromoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                  : [
                      AppColors.secondary,
                      const Color(0xFF2A3F8F),
                      const Color(0xFF3D5AC6),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF0F3460) : AppColors.secondary)
                    .withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Animated floating circles
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(double.infinity, 130),
                    painter: _FloatingCirclesPainter(
                      progress: _ctrl.value,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'AR',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ar_promo_title'.tr(),
                              style: GoogleFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ar_promo_desc'.tr(),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white.withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 3D icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          size: 32,
                          color: AppColors.white.withValues(alpha: 0.9),
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
    );
  }
}

class _FloatingCirclesPainter extends CustomPainter {
  _FloatingCirclesPainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Circle 1 — top right
    final c1x = size.width * 0.85 + math.sin(progress * 2 * math.pi) * 12;
    final c1y = size.height * 0.15 + math.cos(progress * 2 * math.pi) * 8;
    paint.color = AppColors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(c1x, c1y), 45, paint);

    // Circle 2 — bottom left
    final c2x =
        size.width * 0.15 + math.cos(progress * 2 * math.pi + 1) * 10;
    final c2y =
        size.height * 0.8 + math.sin(progress * 2 * math.pi + 1) * 6;
    paint.color = AppColors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(c2x, c2y), 35, paint);

    // Circle 3 — center right
    final c3x =
        size.width * 0.7 + math.sin(progress * 2 * math.pi + 2.5) * 8;
    final c3y =
        size.height * 0.6 + math.cos(progress * 2 * math.pi + 2.5) * 10;
    paint.color = AppColors.white.withValues(alpha: 0.05);
    canvas.drawCircle(Offset(c3x, c3y), 25, paint);
  }

  @override
  bool shouldRepaint(_FloatingCirclesPainter old) => old.progress != progress;
}
