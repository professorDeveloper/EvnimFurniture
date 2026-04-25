import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/model/material_item.dart';
import '../../../home/presentation/widgets/zig_zag_clipper.dart';

class MaterialGridCard extends StatelessWidget {
  const MaterialGridCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.index,
    this.onTap,
  });

  final MaterialListItem item;
  final bool isDark;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipPath(
                clipper: const ZigZagClipper(zigHeight: 5.0, count: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: _buildImage(surface),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textMain,
                  letterSpacing: -0.1,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Color surface) {
    final url = item.previewImage;
    if (url.isEmpty) {
      return ColoredBox(
        color: surface,
        child: const Center(
          child:
              Icon(Icons.texture_rounded, size: 24, color: AppColors.grey300),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 200,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: surface),
      errorWidget: (_, __, ___) => ColoredBox(
        color: surface,
        child: const Center(
          child:
              Icon(Icons.texture_rounded, size: 24, color: AppColors.grey300),
        ),
      ),
    );
  }
}
