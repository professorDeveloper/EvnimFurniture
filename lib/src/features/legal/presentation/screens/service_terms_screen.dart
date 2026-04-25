import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class ServiceTermsScreen extends StatelessWidget {
  const ServiceTermsScreen({super.key});

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
          'service_terms'.tr(),
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
            section('st_use_title', 'st_use_desc'),
            section('st_account_title', 'st_account_desc'),
            section('st_catalog_title', 'st_catalog_desc'),
            section('st_ar_title', 'st_ar_desc'),
            section('st_content_title', 'st_content_desc'),
            section('st_ip_title', 'st_ip_desc'),
            section('st_liability_title', 'st_liability_desc'),
            section('st_modify_title', 'st_modify_desc'),
            section('st_governing_title', 'st_governing_desc'),
            section('st_contact_title', 'st_contact_desc'),
          ],
        ),
      ),
    );
  }
}
