import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_texts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_HelpItem> _items = [
    _HelpItem(titleKey: AppTexts.helpQ1Title, descKey: AppTexts.helpQ1Desc),
    _HelpItem(titleKey: AppTexts.helpQ2Title, descKey: AppTexts.helpQ2Desc),
    _HelpItem(titleKey: AppTexts.helpQ3Title, descKey: AppTexts.helpQ3Desc),
    _HelpItem(titleKey: AppTexts.helpQ4Title, descKey: AppTexts.helpQ4Desc),
    _HelpItem(titleKey: AppTexts.helpQ5Title, descKey: AppTexts.helpQ5Desc),
    _HelpItem(titleKey: AppTexts.helpQ6Title, descKey: AppTexts.helpQ6Desc),
  ];

  static const _phone = '+998557770007';
  static const _telegram = 'https://t.me/evim_uzb';
  static const _instagram = 'https://www.instagram.com/evim_uzb/';
  static const _facebook = 'https://www.facebook.com/61550119921622';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final border = isDark ? AppColors.darkDivider : AppColors.divider;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        centerTitle: true,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'help'.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SocialRow(
              textColor: text,
              onPhone: () => _launchTel(_phone),
              onTelegram: () => _launchUrl(_telegram),
              onInstagram: () => _launchUrl(_instagram),
              onFacebook: () => _launchUrl(_facebook),
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: border),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: border),
            itemBuilder: (context, index) {
              final item = _items[index];
              return InkWell(
                onTap: () =>
                    setState(() => item.isExpanded = !item.isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.titleKey.tr(),
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: text,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: item.isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: subText,
                            ),
                          ),
                        ],
                      ),
                      if (item.isExpanded) ...[
                        const SizedBox(height: 10),
                        Text(
                          item.descKey.tr(),
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.5,
                            color: subText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchUrl(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _HelpItem {
  final String titleKey;
  final String descKey;
  bool isExpanded;

  _HelpItem({
    required this.titleKey,
    required this.descKey,
    this.isExpanded = true,
  });
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.textColor,
    required this.onPhone,
    required this.onTelegram,
    required this.onInstagram,
    required this.onFacebook,
  });

  final Color textColor;
  final VoidCallback onPhone;
  final VoidCallback onTelegram;
  final VoidCallback onInstagram;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _item(asset: AppImages.phone, titleKey: 'phone', onTap: onPhone),
        _item(
            asset: AppImages.telegram,
            titleKey: 'telegram',
            onTap: onTelegram),
        _item(
            asset: AppImages.instagram,
            titleKey: 'instagram',
            onTap: onInstagram),
        _item(
            asset: AppImages.facebook,
            titleKey: 'facebook',
            onTap: onFacebook),
      ],
    );
  }

  Widget _item({
    required String asset,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(asset, width: 54, height: 54),
              const SizedBox(height: 6),
              Text(
                titleKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
