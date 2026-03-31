import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSeeAll,
  });

  final String title;
  final bool isDark;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
          TextButton(
            onPressed: onSeeAll ?? () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.grey500,
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(AppTexts.seeAll.tr()),
          ),
        ],
      ),
    );
  }
}
