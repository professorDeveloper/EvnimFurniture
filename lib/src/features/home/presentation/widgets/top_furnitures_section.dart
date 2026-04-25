import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../../view_all/presentation/screens/view_all_screen.dart';
import '../../domain/model/furniture_item.dart';
import '../../domain/model/material_item.dart';
import 'materials_list_sheet.dart';
import 'section_header.dart';

class TopFurnituresSection extends StatelessWidget {
  const TopFurnituresSection({
    super.key,
    required this.items,
    required this.materials,
  });

  final List<FurnitureItem> items;
  final List<MaterialItem> materials;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double cardW = 150;
    const double imgH = 120;
    const double listH = imgH + 65;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppTexts.topFurnitures.tr(),
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(
            context, Pages.viewAll,
            arguments: ViewAllType.furnitures,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: listH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _FurnitureCard(
              key: ValueKey(items[i].id),
              item: items[i],
              isDark: isDark,
              cardW: cardW,
              onTap: () => showFurnitureDetailSheet(
                context: context,
                furnitureId: items[i].id,
                previewName: items[i].name,
                previewThumbnail: items[i].thumbnailImage,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FurnitureCard extends StatelessWidget {
  const _FurnitureCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.cardW,
    required this.onTap,
  });

  final FurnitureItem item;
  final bool isDark;
  final double cardW;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final imgBg = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;
    final borderC = isDark ? AppColors.darkDivider : const Color(0xFFEEEEEE);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: cardW,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderC, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: imgBg),
                    _buildImage(imgBg),
                    if (item.stats.avgRating > 0)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFD700)),
                              const SizedBox(width: 2),
                              Text(item.stats.avgRating.toStringAsFixed(1),
                                style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: textMain, height: 1.3)),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.description!,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 10, color: textSub)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Color bg) {
    final url = item.thumbnailImage;
    if (url == null || url.isEmpty) {
      return Center(child: Icon(Icons.chair_outlined, size: 40, color: AppColors.grey300));
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 400,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(child: Icon(Icons.chair_outlined, size: 40, color: AppColors.grey300)),
    );
  }
}
