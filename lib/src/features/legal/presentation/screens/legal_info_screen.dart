import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/pages.dart';

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final border = isDark ? AppColors.darkDivider : AppColors.divider;

    Widget tile({
      required IconData icon,
      required String titleKey,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: text),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titleKey.tr(),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: subText),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'legal_info'.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          tile(
            icon: CupertinoIcons.checkmark_shield,
            titleKey: 'privacy_policy',
            onTap: () => Navigator.pushNamed(context, Pages.privacyPolicy),
          ),
          Divider(height: 1, thickness: 0.6, color: border),
          tile(
            icon: CupertinoIcons.doc_text,
            titleKey: 'service_terms',
            onTap: () => Navigator.pushNamed(context, Pages.serviceTerms),
          ),
          Divider(height: 1, thickness: 0.6, color: border),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'legal_info_hint'.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: subText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
