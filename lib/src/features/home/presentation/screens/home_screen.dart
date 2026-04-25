import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:evim_furniture/src/features/view_all/presentation/screens/view_all_screen.dart';
import 'package:evim_furniture/src/core/services/notification_service.dart';
import 'package:evim_furniture/src/core/constants/app_icons.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/features/home/domain/model/home_data.dart';
import 'package:evim_furniture/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/banner_carusel.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/category_section.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/material_section.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/stories_list.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/top_furnitures_section.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/model/combination_item.dart';
import '../../domain/model/furniture_item.dart';
import '../widgets/section_header.dart';
import '../widgets/materials_list_sheet.dart';
import '../widgets/top_combinations_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const LoadHomeData()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
          appBar: _buildAppBar(isDark, context),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeLoaded(:final data) => _HomeBody(
                    data: data,
                    isDark: isDark,
                  ),
                HomeError(:final message) => _ErrorView(
                    message: message,
                    isDark: isDark,
                    onRetry: () =>
                        context.read<HomeBloc>().add(const LoadHomeData()),
                  ),
                _ => _HomeLoadingBody(isDark: isDark),
              };
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: SvgPicture.asset(
        AppIcons.appbarIcon,
        height: 33,
        colorFilter: isDark
            ? const ColorFilter.mode(AppColors.white, BlendMode.srcIn)
            : null,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  size: 24,
                ),
                onPressed: () async {
                  if (!NotificationService.instance.isPermissionGranted) {
                    await NotificationService.instance.requestPermission();
                  }
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/notifications');
                  }
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody({
    required this.data,
    required this.isDark,
  });

  final HomeData data;
  final bool isDark;

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<HomeBloc>().add(const LoadMoreCombinations());
    }
  }

  List<Widget> _buildFurnituresGrid(BuildContext context, bool isDark) {
    final data = widget.data;
    if (data.topFurniture.isEmpty) return [];

    return [
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
      SliverToBoxAdapter(
        child: SectionHeader(
          title: AppTexts.topFurnitures.tr(),
          isDark: isDark,
          onSeeAll: () => Navigator.pushNamed(
            context, Pages.viewAll,
            arguments: ViewAllType.furnitures,
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => RepaintBoundary(
              child: _FurnitureGridCard(
                item: data.topFurniture[i],
                isDark: isDark,
              ),
            ),
            childCount: data.topFurniture.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 220,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = widget.isDark;

    return RefreshIndicator(
      color: AppColors.primary,
      displacement: 20,
      onRefresh: () {
        context.read<HomeBloc>().add(const RefreshHomeData());
        return context
            .read<HomeBloc>()
            .stream
            .firstWhere((s) => s is HomeLoaded || s is HomeError);
      },
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (data.stories.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: RepaintBoundary(child: StoriesList(items: data.stories)),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: BannerCarousel(banners: data.banners, isDark: isDark),
            ),
          ),
          if (data.categories.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child:
                  RepaintBoundary(child: CategoryList(items: data.categories)),
            ),
          ],
          if (data.topCombinations.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TopCombinationsSection(items: data.topCombinations),
              ),
            ),
          ],
          if (data.topMaterials.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                  child: MaterialsSection(items: data.topMaterials)),
            ),
          ],
          ..._buildFurnituresGrid(context, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _HomeLoadingBody extends StatefulWidget {
  const _HomeLoadingBody({required this.isDark});

  final bool isDark;

  @override
  State<_HomeLoadingBody> createState() => _HomeLoadingBodyState();
}

class _HomeLoadingBodyState extends State<_HomeLoadingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.65)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
                child: _StoriesSkeleton(
                    isDark: widget.isDark, opacity: _anim.value)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _Bone(
                  width: double.infinity,
                  height: 180,
                  radius: 16,
                  isDark: widget.isDark,
                  opacity: _anim.value,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
                child: _CategoriesSkeleton(
                    isDark: widget.isDark, opacity: _anim.value)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
                child: _CardsSkeleton(
                    isDark: widget.isDark,
                    opacity: _anim.value,
                    cardAspect: 1.15,
                    widthFactor: 0.44)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
                child: _CardsSkeleton(
                    isDark: widget.isDark,
                    opacity: _anim.value,
                    cardAspect: 1.55,
                    widthFactor: 0.36)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
                child: _CombinationsSkeleton(
                    isDark: widget.isDark, opacity: _anim.value)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

class _StoriesSkeleton extends StatelessWidget {
  const _StoriesSkeleton({required this.isDark, required this.opacity});
  final bool isDark;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => Column(
          children: [
            _Bone(
              width: 65,
              height: 65,
              radius: 34,
              isDark: isDark,
              opacity: (opacity - i * 0.04).clamp(0.1, 0.8),
            ),
            const SizedBox(height: 6),
            _Bone(
              width: 48,
              height: 10,
              isDark: isDark,
              opacity: (opacity - i * 0.04).clamp(0.1, 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton({required this.isDark, required this.opacity});
  final bool isDark;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              _Bone(width: 100, height: 16, isDark: isDark, opacity: opacity),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < 5 ? 14 : 0),
              child: Column(
                children: [
                  _Bone(
                    width: 66,
                    height: 66,
                    radius: 18,
                    isDark: isDark,
                    opacity: (opacity - i * 0.04).clamp(0.1, 0.8),
                  ),
                  const SizedBox(height: 7),
                  _Bone(
                    width: 48,
                    height: 10,
                    isDark: isDark,
                    opacity: (opacity - i * 0.04).clamp(0.1, 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardsSkeleton extends StatelessWidget {
  const _CardsSkeleton({
    required this.isDark,
    required this.opacity,
    required this.cardAspect,
    required this.widthFactor,
  });
  final bool isDark;
  final double opacity;
  final double cardAspect;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardW = screenWidth * widthFactor;
    final double cardH = cardW * cardAspect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              _Bone(width: 120, height: 16, isDark: isDark, opacity: opacity),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardH + 8,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: 3,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < 2 ? 14 : 0),
              child: _Bone(
                width: cardW,
                height: cardH,
                radius: 20,
                isDark: isDark,
                opacity: (opacity - i * 0.06).clamp(0.1, 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.isDark,
    required this.opacity,
    this.radius = 8,
  });

  final double width;
  final double height;
  final bool isDark;
  final double opacity;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: (isDark ? AppColors.darkSurfaceVariant : AppColors.grey200)
            .withValues(alpha: opacity),
      ),
    );
  }
}

class _CombinationsSkeleton extends StatelessWidget {
  const _CombinationsSkeleton({required this.isDark, required this.opacity});
  final bool isDark;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double cardW = (w * 0.42).clamp(150.0, 180.0);
    final double imgH = cardW * 0.85;
    const double infoH = 85.0;
    final double listH = imgH + infoH + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              _Bone(width: 130, height: 16, isDark: isDark, opacity: opacity),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: listH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: 3,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
              child: Container(
                width: cardW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(
                      width: cardW,
                      height: imgH,
                      radius: 18,
                      isDark: isDark,
                      opacity: (opacity - i * 0.06).clamp(0.1, 0.8),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(
                            width: cardW * 0.7,
                            height: 12,
                            isDark: isDark,
                            opacity: (opacity - i * 0.06).clamp(0.1, 0.8),
                          ),
                          const SizedBox(height: 6),
                          _Bone(
                            width: cardW * 0.5,
                            height: 10,
                            isDark: isDark,
                            opacity: (opacity - i * 0.06).clamp(0.1, 0.8),
                          ),
                          const SizedBox(height: 8),
                          _Bone(
                            width: 50,
                            height: 12,
                            radius: 6,
                            isDark: isDark,
                            opacity: (opacity - i * 0.06).clamp(0.1, 0.8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FurnitureGridCard extends StatelessWidget {
  const _FurnitureGridCard({required this.item, required this.isDark});

  final FurnitureItem item;
  final bool isDark;

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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: imgBg),
                    item.thumbnailImage != null && item.thumbnailImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.thumbnailImage!,
                            memCacheWidth: 400,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ColoredBox(color: imgBg),
                            errorWidget: (_, __, ___) => Center(
                              child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300)),
                          )
                        : Center(child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300)),
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
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: isDark ? AppColors.grey600 : AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              AppTexts.errorNoConnection.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTexts.errorNoConnectionDesc.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                AppTexts.errorRetry.tr(),
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
