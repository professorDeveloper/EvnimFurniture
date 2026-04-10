import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../domain/model/combination_item.dart';
import 'section_header.dart';

class TopCombinationsSection extends StatelessWidget {
  const TopCombinationsSection({super.key, required this.items});

  final List<CombinationItem> items;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double w = MediaQuery.of(context).size.width;

    final double cardW = (w * 0.42).clamp(150.0, 180.0);
    final double imgH = cardW * 0.85;

    const double infoH = 85.0;
    final double listH = imgH + infoH + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppTexts.topCombinations.tr(), isDark: isDark),
        const SizedBox(height: 12),
        SizedBox(
          height: listH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 12 : 0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(items[i].furnitureMaterialId),
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
                child: _CombinationCard(
                  item: items[i],
                  isDark: isDark,
                  cardW: cardW,
                  imgH: imgH,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CombinationCard extends StatefulWidget {
  const _CombinationCard({
    required this.item,
    required this.isDark,
    required this.cardW,
    required this.imgH,
  });

  final CombinationItem item;
  final bool isDark;
  final double cardW;
  final double imgH;

  @override
  State<_CombinationCard> createState() => _CombinationCardState();
}

class _CombinationCardState extends State<_CombinationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(
      Pages.furnitureDetail,
      arguments: {
        'furnitureId': widget.item.furniture.id,
        'furnitureMaterialId': widget.item.furnitureMaterialId,
      },
    );
  }

  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final item = widget.item;
    final cw = widget.cardW;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final imgBg =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2F2F2);
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;
    final borderC = isDark ? AppColors.darkDivider : AppColors.grey200;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) => Opacity(opacity: _pressAnim.value, child: child),
        child: Container(
          width: cw,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderC, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: isDark ? 0.24 : 0.06),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cw,
                  height: widget.imgH,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: imgBg),
                      _buildImage(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.furniture.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                          letterSpacing: -0.1,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.material.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: textSub,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _buildColorInfo(textSub),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final String? url = widget.item.displayImage;
    final Color bg =
        widget.isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2F2F2);
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(Icons.view_in_ar_outlined,
            size: widget.cardW * 0.30, color: AppColors.grey300),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.view_in_ar_outlined,
            size: widget.cardW * 0.30, color: AppColors.grey300),
      ),
    );
  }

  Widget _buildColorInfo(Color textSub) {
    final color = widget.item.defaultColor;
    if (color == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _parseColor(color.hexCode),
            border: Border.all(color: AppColors.grey300, width: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            color.name,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: textSub,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexCode) {
    try {
      final String hex = hexCode.replaceFirst('#', '').toUpperCase();
      if (hex.length != 6) return Colors.grey;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
