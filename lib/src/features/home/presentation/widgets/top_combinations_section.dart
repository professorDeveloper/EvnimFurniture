import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../../view_all/presentation/screens/view_all_screen.dart';
import '../../domain/model/combination_item.dart';
import 'section_header.dart';

class TopCombinationsSection extends StatelessWidget {
  const TopCombinationsSection({super.key, required this.items});

  final List<CombinationItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppTexts.topCombinations.tr(),
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(
            context, Pages.viewAll,
            arguments: ViewAllType.combinations,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _CombinationCard(
              key: ValueKey(items[i].furnitureMaterialId),
              item: items[i],
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _CombinationCard extends StatelessWidget {
  const _CombinationCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  final CombinationItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final imgBg = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed(
          Pages.furnitureDetail,
          arguments: {
            'furnitureId': item.furniture.id,
            'furnitureMaterialId': item.furnitureMaterialId,
          },
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: imgBg),
              _buildImage(imgBg),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.furniture.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white, height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.material.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white70),
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

  Widget _buildImage(Color bg) {
    final url = item.displayImage;
    if (url == null || url.isEmpty) {
      return Center(child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300));
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 400,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300)),
    );
  }
}
