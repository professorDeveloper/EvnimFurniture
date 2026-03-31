import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/model/story_item.dart';
import '../screens/story_viewer_screen.dart';

class StoriesList extends StatelessWidget {
  const StoriesList(
      {super.key, required this.items, this.horizontalPadding = 16});

  final List<StoryItem> items;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double w = MediaQuery.of(context).size.width;
    final bool isTablet = w >= 600;

    final double cellSize = isTablet ? 85 : 70;
    final double height = isTablet ? 120 : 104;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _StoryCell(
          item: items[index],
          isDark: isDark,
          size: cellSize,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black,
                pageBuilder: (_, __, ___) => StoryViewerScreen(
                  items: items,
                  initialIndex: index,
                ),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 280),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StoryCell extends StatelessWidget {
  const _StoryCell({
    required this.item,
    required this.isDark,
    required this.onTap,
    this.size = 70,
  });

  final StoryItem item;
  final bool isDark;
  final VoidCallback onTap;
  final double size;

  static const List<Color> _unseenGradient = [
    Color(0xFFFFD700),
    Color(0xFFFF7043),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isUnseen = !item.isSeen;
    final Color bgGap = isDark ? AppColors.darkBackground : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnseen
                    ? const LinearGradient(
                  colors: _unseenGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isUnseen ? null : AppColors.grey300,
              ),
              padding: EdgeInsets.all(size * 0.036),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgGap,
                ),
                padding: EdgeInsets.all(size * 0.029),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: item.displayImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => ColoredBox(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.grey100,
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.grey100,
                      child: Icon(Icons.chair_outlined,
                          size: size * 0.31, color: AppColors.grey400),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size * 0.1),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: size * 0.157,
                fontWeight: isUnseen ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? (isUnseen
                    ? AppColors.darkOnSurface
                    : AppColors.darkOnSurface.withValues(alpha: 0.45))
                    : (isUnseen ? AppColors.onSurface : AppColors.grey400),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
