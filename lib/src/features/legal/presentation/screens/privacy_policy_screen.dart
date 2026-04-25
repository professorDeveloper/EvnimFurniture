import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;

    final sectionTitleStyle = GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: text,
      height: 1.25,
    );

    final bodyStyle = GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: subText,
      height: 1.55,
    );

    Widget section(String titleKey, String descKey) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleKey.tr(), style: sectionTitleStyle),
            const SizedBox(height: 8),
            Text(descKey.tr(), style: bodyStyle),
          ],
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
          'privacy_policy'.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section('pp_intro_title', 'pp_intro_desc'),
            section('pp_collect_title', 'pp_collect_desc'),
            section('pp_use_title', 'pp_use_desc'),
            section('pp_sharing_title', 'pp_sharing_desc'),
            section('pp_retention_title', 'pp_retention_desc'),
            section('pp_rights_title', 'pp_rights_desc'),
            section('pp_security_title', 'pp_security_desc'),
            section('pp_cookies_title', 'pp_cookies_desc'),
            section('pp_changes_title', 'pp_changes_desc'),
            section('pp_contact_title', 'pp_contact_desc'),
          ],
        ),
      ),
    );
  }
}
