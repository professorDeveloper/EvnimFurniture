import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/zig_zag_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../domain/model/material_item.dart';
import 'section_header.dart';

class MaterialsSection extends StatelessWidget {
  const MaterialsSection(
      {super.key, required this.items, this.horizontalPadding = 16});

  final List<MaterialItem> items;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double w = MediaQuery.of(context).size.width;
    final bool isTablet = w >= 600;

    final double cardW = isTablet ? w * 0.25 : w * 0.32;
    final double imgH = cardW * 0.9;
    const double zigH = 4.0;
    final double infoH = 30.0 + 4.0 + zigH;
    final double listH = imgH + infoH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppTexts.materialsTitle.tr(), isDark: isDark),
        const SizedBox(height: 12),
        SizedBox(
          height: listH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(items[i].id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + i * 70),
                curve: Curves.easeOutQuart,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(18 * (1 - v), 0),
                    child: child,
                  ),
                ),
                child: _MaterialCard(
                  item: items[i],
                  isDark: isDark,
                  cardW: cardW,
                  imgH: imgH,
                  zigH: zigH,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.item,
    required this.isDark,
    required this.cardW,
    required this.imgH,
    required this.zigH,
  });

  final MaterialItem item;
  final bool isDark;
  final double cardW;
  final double imgH;
  final double zigH;

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;
    final textCount = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.4)
        : AppColors.grey400;

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: SizedBox(
        width: cardW,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipPath(
              clipper: ZigZagClipper(zigHeight: zigH, count: 7),
              child: SizedBox(
                width: cardW,
                height: imgH,
                child: _buildImage(),
              ),
            ),
            SizedBox(height: zigH * 0.8),
            SizedBox(
              height: 16,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                  letterSpacing: -0.1,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 13,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (item.defaultColor != null) ...[
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.defaultColor!.color,
                        border:
                        Border.all(color: AppColors.grey300, width: 0.8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.defaultColor!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          height: 1.0,
                          color: textSub,
                        ),
                      ),
                    ),
                  ],
                  if (item.stats.furnitureCount > 0) ...[
                    const Spacer(),
                    Text(
                      '${item.stats.furnitureCount} ta',
                      style: GoogleFonts.dmSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                        color: textCount,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? url = item.firstImage;
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
        child: const Center(
          child:
          Icon(Icons.texture_rounded, size: 22, color: AppColors.grey400),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
      ),
      errorWidget: (_, __, ___) => ColoredBox(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
        child: const Center(
          child:
          Icon(Icons.texture_rounded, size: 22, color: AppColors.grey400),
        ),
      ),
    );
  }
}
