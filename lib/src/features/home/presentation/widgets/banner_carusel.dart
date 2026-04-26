import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/router/pages.dart';
import '../../domain/model/banner_item.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.isDark,
    this.height = 200,
    this.horizontalPadding = 16,
  });

  final List<BannerItem> banners;
  final bool isDark;
  final double height;
  final double horizontalPadding;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: widget.height,
            width: double.infinity,
            color: widget.isDark ? AppColors.darkSurface : AppColors.grey100,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: AppColors.grey400),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1,
            autoPlay: widget.banners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
          itemBuilder: (_, index, __) => _BannerImage(
            banner: widget.banners[index],
            height: widget.height,
            horizontalPadding: widget.horizontalPadding,
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          _DotsIndicator(
            count: widget.banners.length,
            current: _current,
            isDark: widget.isDark,
          ),
        ],
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.isDark,
  });

  final int count;
  final int current;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.grey700 : AppColors.grey300),
          ),
        );
      }),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({
    required this.banner,
    required this.height,
    required this.horizontalPadding,
  });

  final BannerItem banner;
  final double height;
  final double horizontalPadding;

  void _openDetail(BuildContext context) {
    if (!banner.hasLink) return;
    HapticFeedback.lightImpact();

    final materialId = banner.furnitureCombinationId ?? banner.furnitureMaterialId;
    Navigator.of(context).pushNamed(
      Pages.furnitureDetail,
      arguments: {
        'furnitureId': '',
        'furnitureMaterialId': materialId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final hasLink = banner.hasLink;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: banner.imageUrl,
                memCacheWidth: 800,
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(color: placeholderColor),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: placeholderColor,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.grey400),
                ),
              ),
              if (hasLink)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppTexts.seeAll.tr(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.black87),
                            ],
                          ),
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
}
