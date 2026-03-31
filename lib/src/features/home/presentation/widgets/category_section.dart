import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../domain/model/category_model.dart';
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
    final bool isTablet = w >= 600;

    final double cardW =
    isTablet ? (w * 0.15).clamp(70.0, 100.0) : (w * 0.19).clamp(60.0, 80.0);
    final double cardH = cardW * 0.85;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppTexts.categoriesTitle.tr(), isDark: isDark),
        const SizedBox(height: 12),
        SizedBox(
          height: cardH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(items[i].id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 260 + i * 60),
                curve: Curves.easeOutQuart,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(18 * (1 - v), 0),
                    child: child,
                  ),
                ),
                child: _CategoryCard(
                  item: items[i],
                  isDark: isDark,
                  cardW: cardW,
                  cardH: cardH,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.isDark,
    required this.cardW,
    required this.cardH,
  });

  final CategoryItem item;
  final bool isDark;
  final double cardW;
  final double cardH;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.10),
              blurRadius: 10,
              spreadRadius: -3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: (cardW * 0.13).clamp(9.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? url = item.coverImage;
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
        child: Center(
          child: Icon(
            Icons.category_outlined,
            size: cardW * 0.3,
            color: AppColors.grey400,
          ),
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
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
        child: Center(
          child: Icon(
            Icons.category_outlined,
            size: cardW * 0.3,
            color: AppColors.grey400,
          ),
        ),
      ),
    );
  }
}
