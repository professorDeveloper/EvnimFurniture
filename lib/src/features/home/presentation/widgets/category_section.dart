import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../../category/domain/model/category_model.dart';
import 'section_header.dart';

class CategoryList extends StatelessWidget {
  const CategoryList(
      {super.key, required this.items, this.horizontalPadding = 16});

  final List<CategoryItem> items;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double w = MediaQuery.of(context).size.width;

    const double imgSize = 60;
    const double gap = 16;
    final int visibleCount =
        ((w - horizontalPadding * 2 + gap) / (imgSize + gap)).floor().clamp(4, 6);
    final double cardW =
        (w - horizontalPadding * 2 - gap * (visibleCount - 1)) / visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppTexts.categoriesTitle.tr(),
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(
            context,
            Pages.categoriesViewAll,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardW + 28,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            physics: items.length <= visibleCount
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (_, i) => _CategoryCard(
              key: ValueKey(items[i].id),
              item: items[i],
              isDark: isDark,
              cardW: cardW,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.cardW,
  });

  final CategoryItem item;
  final bool isDark;
  final double cardW;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0EEEC);
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed(
          Pages.categoryFurniture,
          arguments: item,
        );
      },
      child: SizedBox(
        width: cardW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cardW,
              height: cardW,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardW * 0.3),
                color: bgColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardW * 0.3),
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? url = item.coverImage;
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(
          Icons.category_outlined,
          size: cardW * 0.35,
          color: AppColors.grey400,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 200,
      fit: BoxFit.cover,
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => Center(
        child: Icon(
          Icons.category_outlined,
          size: cardW * 0.35,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}
