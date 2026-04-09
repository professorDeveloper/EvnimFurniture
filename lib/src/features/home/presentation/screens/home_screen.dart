import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_icons.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/features/home/domain/model/home_data.dart';
import 'package:evim_furniture/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/banner_carusel.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/category_section.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/material_section.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/stories_list.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/top_combinations_section.dart';
import 'package:evim_furniture/src/features/home/presentation/widgets/top_furnitures_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _banners = [
    'https://cdn.azamov.me/images/banners/1773897035826-aa.png',
  ];

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
                  banners: _banners,
                  isDark: isDark,
                ),
                HomeError(:final message) => _ErrorView(
                  message: message,
                  isDark: isDark,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const LoadHomeData()),
                ),
                _ => _HomeLoadingBody(isDark: isDark, banners: _banners),
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
                onPressed: () {},
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

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.data,
    required this.banners,
    required this.isDark,
  });

  final HomeData data;
  final List<String> banners;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: StoriesList(items: data.stories)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: BannerCarousel(banners: banners, isDark: isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: CategoryList(items: data.categories)),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
              child: TopFurnituresSection(
                items: data.topFurniture,
                materials: data.topMaterials,
              )),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(child: MaterialsSection(items: data.topMaterials)),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          if (data.topCombinations.isNotEmpty)
            SliverToBoxAdapter(
                child: TopCombinationsSection(items: data.topCombinations)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _HomeLoadingBody extends StatefulWidget {
  const _HomeLoadingBody({required this.isDark, required this.banners});

  final bool isDark;
  final List<String> banners;

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
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: BannerCarousel(
                  banners: widget.banners, isDark: widget.isDark),
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
              'Internetga ulanishda muammo',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarmoq aloqasini tekshirib qayta urinib ko\'ring',
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
                'Qayta yuklash',
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