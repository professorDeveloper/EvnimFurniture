import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/router/pages.dart';
import '../../domain/model/favourite_item.dart';
import '../bloc/favourites_bloc.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppTexts.favouritesTitle.tr(),
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoggedIn
          ? BlocBuilder<FavouritesBloc, FavouritesState>(
              builder: (context, state) {
                if (state is FavouritesLoading || state is FavouritesInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  );
                }
                if (state is FavouritesError) {
                  return AppErrorState(
                    onRetry: () => context
                        .read<FavouritesBloc>()
                        .add(FavouritesLoadRequested()),
                    isDark: isDark,
                  );
                }
                if (state is FavouritesLoaded) {
                  if (state.items.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.favorite_outline_rounded,
                      title: AppTexts.favouritesEmpty.tr(),
                      description: AppTexts.favouritesEmptyDesc.tr(),
                      isDark: isDark,
                    );
                  }
                  return _FavouritesList(
                    items: state.items,
                    isDark: isDark,
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : _LoginPrompt(isDark: isDark),
    );
  }
}

class _FavouritesList extends StatelessWidget {
  const _FavouritesList({required this.items, required this.isDark});

  final List<FavouriteItem> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final crossCount = w >= 600 ? 3 : 2;
    final cardW = (w - 16 * 2 - 10 * (crossCount - 1)) / crossCount;
    final imgH = cardW * 0.85;
    final listH = imgH + 62;

    return RefreshIndicator(
      color: AppColors.primary,
      displacement: 20,
      onRefresh: () async {
        context.read<FavouritesBloc>().add(FavouritesLoadRequested());
        await context
            .read<FavouritesBloc>()
            .stream
            .firstWhere((s) => s is FavouritesLoaded || s is FavouritesError);
      },
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          mainAxisExtent: listH,
        ),
        cacheExtent: 400,
        itemCount: items.length,
        itemBuilder: (_, i) => _FavouriteCard(
          item: items[i],
          isDark: isDark,
          imgH: imgH,
        ),
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard({
    required this.item,
    required this.isDark,
    required this.imgH,
  });

  final FavouriteItem item;
  final bool isDark;
  final double imgH;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final imgBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2F2F2);
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;
    final borderC = isDark ? AppColors.darkDivider : AppColors.grey200;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed(
          Pages.furnitureDetail,
          arguments: {
            'furnitureId': item.furnitureId,
            'furnitureMaterialId': item.furnitureMaterialId,
          },
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
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<FavouritesBloc>().add(
                                FavouriteRemoveRequested(
                                    furnitureMaterialId:
                                        item.furnitureMaterialId),
                              );
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface.withValues(alpha: 0.75)
                                : AppColors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
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
                      item.furnitureName,
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
                    if (item.materialName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.materialName,
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
    if (url == null || url.isEmpty || url == 'string') {
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.12)
                    : AppColors.secondary50,
              ),
              child: Icon(
                Icons.favorite_outline_rounded,
                size: 40,
                color: isDark ? AppColors.secondary300 : AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppTexts.favouritesEmpty.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.favouritesEmptyDesc.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark ? AppColors.grey400 : AppColors.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Pages.login),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'login'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
