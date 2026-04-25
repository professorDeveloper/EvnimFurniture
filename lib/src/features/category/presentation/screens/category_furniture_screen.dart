import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/di/injection.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../home/presentation/widgets/materials_list_sheet.dart';
import '../../domain/model/category_model.dart';
import '../bloc/category_furniture_bloc.dart';
import '../bloc/category_furniture_event.dart';
import '../bloc/category_furniture_state.dart';

class CategoryFurnitureScreen extends StatelessWidget {
  const CategoryFurnitureScreen({super.key, required this.category});

  final CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryFurnitureBloc>()
        ..add(LoadCategoryFurniture(slug: category.slug)),
      child: _CategoryFurnitureView(category: category),
    );
  }
}

class _CategoryFurnitureView extends StatefulWidget {
  const _CategoryFurnitureView({required this.category});

  final CategoryItem category;

  @override
  State<_CategoryFurnitureView> createState() => _CategoryFurnitureViewState();
}

class _CategoryFurnitureViewState extends State<_CategoryFurnitureView>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _searchController.addListener(() {
      context
          .read<CategoryFurnitureBloc>()
          .add(SearchCategoryFurniture(query: _searchController.text));
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    HapticFeedback.selectionClick();
    setState(() => _isSearching = true);
    _animController.forward();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    _animController.reverse().then((_) {
      if (mounted) setState(() => _isSearching = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;
    final divider = isDark ? AppColors.darkDivider : AppColors.grey200;
    final appBarBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildAppBar(appBarBg, textMain, textSub, isDark),
          Divider(height: 1, color: divider),
          Expanded(
            child: BlocBuilder<CategoryFurnitureBloc, CategoryFurnitureState>(
              builder: (context, state) {
                return switch (state) {
                  CategoryFurnitureLoaded(:final filteredItems, :final query) =>
                    filteredItems.isEmpty && query.isNotEmpty
                        ? _buildNoResults(isDark)
                        : _buildGrid(filteredItems, isDark),
                  CategoryFurnitureError() => _buildError(isDark),
                  _ => const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      Color appBarBg, Color textMain, Color textSub, bool isDark) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Container(
          color: appBarBg,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: ReverseAnimation(_fadeAnim),
                      child: IgnorePointer(
                        ignoring: _isSearching,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 20, color: textMain),
                            ),
                            const SizedBox(width: 4),
                            if (widget.category.coverImage != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.category.coverImage!,
                                    memCacheWidth: 200,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => ColoredBox(
                                      color: isDark
                                          ? AppColors.darkSurfaceVariant
                                          : AppColors.grey200,
                                    ),
                                    errorWidget: (_, __, ___) => ColoredBox(
                                      color: isDark
                                          ? AppColors.darkSurfaceVariant
                                          : AppColors.grey200,
                                      child: const Icon(
                                          Icons.category_outlined,
                                          size: 16,
                                          color: AppColors.grey400),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.category.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textMain,
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.category.furnitureCount > 0)
                                    Text(
                                      AppTexts.categoryFurnitureCount.tr(args: ['${widget.category.furnitureCount}']),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: textSub,
                                        height: 1.3,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _openSearch,
                              icon: Icon(Icons.search_rounded,
                                  size: 22, color: textMain),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: IgnorePointer(
                          ignoring: !_isSearching,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _closeSearch,
                                icon: Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 20, color: textMain),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SearchField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  isDark: isDark,
                                  textMain: textMain,
                                  textSub: textSub,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(bool isDark) {
    return AppErrorState(
      onRetry: () => context.read<CategoryFurnitureBloc>().add(
          LoadCategoryFurniture(slug: widget.category.slug)),
      isDark: isDark,
    );
  }

  Widget _buildNoResults(bool isDark) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: AppTexts.searchNoResults.tr(),
      isDark: isDark,
    );
  }

  Widget _buildGrid(List<FurnitureItem> items, bool isDark) {
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;

    return CustomScrollView(
      slivers: [
        if (widget.category.coverImage != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.category.coverImage!,
                      memCacheWidth: 800,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => ColoredBox(color: surface),
                      errorWidget: (_, __, ___) => ColoredBox(color: surface),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.category.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (items.isNotEmpty)
                            Text(
                              AppTexts.categoryFurnitureCount.tr(args: ['${items.length}']),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              mainAxisExtent: 195,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _FurnitureCard(
                item: items[i],
                isDark: isDark,
                surface: surface,
                textMain: textMain,
                textSub: textSub,
              ),
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _FurnitureCard extends StatelessWidget {
  const _FurnitureCard({
    required this.item,
    required this.isDark,
    required this.surface,
    required this.textMain,
    required this.textSub,
  });

  final FurnitureItem item;
  final bool isDark;
  final Color surface;
  final Color textMain;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          showFurnitureDetailSheet(
            context: context,
            furnitureId: item.id,
            previewName: item.name,
            previewThumbnail: item.thumbnailImage,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: surface),
                    _buildImage(),
                    if (item.stats.avgRating > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                    .withValues(alpha: 0.85)
                                : AppColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 9, color: Color(0xFFFFD700)),
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
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.stats.materialCount > 0
                    ? AppTexts.categoryMaterialCount.tr(args: ['${item.stats.materialCount}'])
                    : ' ',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: textSub,
                  height: 1.0,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
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
      placeholder: (_, __) => ColoredBox(color: surface),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.chair_outlined, size: 36, color: AppColors.grey300),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.textMain,
    required this.textSub,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Color textMain;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.dmSans(
            fontSize: 14, color: textMain, fontWeight: FontWeight.w500, height: 1.0),
        decoration: InputDecoration(
          hintText: AppTexts.searchHint.tr(),
          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: textSub, height: 1.0),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: textSub),
          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clear,
                    child: Icon(Icons.close_rounded, size: 16, color: textSub),
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onSubmitted: (_) => focusNode.unfocus(),
      ),
    );
  }
}
