import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../home/presentation/widgets/materials_list_sheet.dart';

class ViewAllFurnitureCard extends StatelessWidget {
  const ViewAllFurnitureCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.imgH,
  });

  final FurnitureItem item;
  final bool isDark;
  final double imgH;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final imgBg = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;
    final borderC = isDark ? AppColors.darkDivider : AppColors.grey200;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showFurnitureDetailSheet(
          context: context,
          furnitureId: item.id,
          previewName: item.name,
          previewThumbnail: item.thumbnailImage,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderC, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: imgH,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: imgBg),
                    _buildImage(imgBg),
                    if (item.stats.avgRating > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                    .withValues(alpha: 0.85)
                                : AppColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 10, color: Color(0xFFFFD700)),
                              const SizedBox(width: 2),
                              Text(
                                item.stats.avgRating.toStringAsFixed(1),
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textMain,
                        letterSpacing: -0.1,
                        height: 1.25,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: textSub,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Color bg) {
    final url = item.thumbnailImage;
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 400,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300),
      ),
    );
  }
}
