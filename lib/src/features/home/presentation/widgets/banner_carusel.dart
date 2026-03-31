import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.isDark,
    this.height = 180,
    this.horizontalPadding = 16,
  });

  final List<String> banners;
  final bool isDark;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        viewportFraction: 1,
        autoPlay: banners.isNotEmpty,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayCurve: Curves.easeInOut,
      ),
      items: banners.isEmpty
          ? <Widget>[
        _BannerPlaceholder(
            isDark: isDark,
            height: height,
            horizontalPadding: horizontalPadding)
      ]
          : banners
          .map((String url) => _BannerImage(
          url: url,
          height: height,
          horizontalPadding: horizontalPadding))
          .toList(),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder(
      {required this.isDark,
        required this.height,
        required this.horizontalPadding});

  final bool isDark;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: height,
          width: double.infinity,
          color: isDark ? AppColors.darkSurface : AppColors.grey100,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, color: AppColors.grey400),
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage(
      {required this.url,
        required this.height,
        required this.horizontalPadding});

  final String url;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: url,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(color: AppColors.grey100),
          errorWidget: (_, __, ___) => const ColoredBox(
            color: AppColors.grey100,
            child: Icon(Icons.broken_image_outlined, color: AppColors.grey400),
          ),
        ),
      ),
    );
  }
}
