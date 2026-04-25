import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/pages.dart';
import '../../../home/domain/model/combination_item.dart';
import '../../../home/domain/model/furniture_item.dart';
import '../../../home/domain/model/material_item.dart' as home;
import '../../../home/domain/usecases/get_materials_furniture_usecase.dart';
import '../../../home/presentation/widgets/material_furnitures_sheet.dart';
import '../../../materials/data/model/material_item.dart';
import '../bloc/view_all_bloc.dart';
import '../widgets/view_all_combination_card.dart';
import '../widgets/view_all_furniture_card.dart';
import '../widgets/view_all_material_card.dart';

enum ViewAllType { furnitures, combinations, materials }

class ViewAllScreen extends StatelessWidget {
  const ViewAllScreen({super.key, required this.type});

  final ViewAllType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ViewAllBloc(
        repository: sl(),
        type: type,
      )..add(ViewAllFetched()),
      child: _ViewAllBody(type: type),
    );
  }
}

class _ViewAllBody extends StatefulWidget {
  const _ViewAllBody({required this.type});

  final ViewAllType type;

  @override
  State<_ViewAllBody> createState() => _ViewAllBodyState();
}

class _ViewAllBodyState extends State<_ViewAllBody> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ViewAllBloc>().add(ViewAllNextPageFetched());
    }
  }

  String get _title {
    switch (widget.type) {
      case ViewAllType.furnitures:
        return AppTexts.topFurnitures.tr();
      case ViewAllType.combinations:
        return AppTexts.topCombinations.tr();
      case ViewAllType.materials:
        return AppTexts.materialsTitle.tr();
    }
  }

  int _crossAxisCount(double width) {
    if (widget.type == ViewAllType.materials) {
      return width >= 600 ? 4 : 3;
    }
    return width >= 600 ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final searchBg = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final hintColor = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.35)
        : AppColors.grey400;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, textMain, searchBg, hintColor),
            Expanded(
              child: BlocBuilder<ViewAllBloc, ViewAllState>(
                builder: (context, state) {
                  if (state is ViewAllLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is ViewAllFailure) {
                    return _buildError(isDark);
                  }
                  if (state is ViewAllLoaded) {
                    if (state.items.isEmpty) {
                      return _buildEmpty(isDark);
                    }
                    return _buildGrid(state, isDark);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color textMain,
    Color searchBg,
    Color hintColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: textMain,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _title,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: searchBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => context
                    .read<ViewAllBloc>()
                    .add(ViewAllSearchChanged(query: q)),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textMain,
                ),
                decoration: InputDecoration(
                  hintText: AppTexts.searchHint.tr(),
                  hintStyle:
                      GoogleFonts.dmSans(fontSize: 14, color: hintColor),
                  prefixIcon:
                      Icon(Icons.search_rounded, size: 20, color: hintColor),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 40, minHeight: 44),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, __) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context
                                  .read<ViewAllBloc>()
                                  .add(ViewAllSearchChanged(query: ''));
                            },
                            child: Icon(Icons.close_rounded,
                                size: 18, color: hintColor),
                          ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ViewAllLoaded state, bool isDark) {
    final w = MediaQuery.of(context).size.width;
    final cross = _crossAxisCount(w);
    final cardW = (w - 32 - 10 * (cross - 1)) / cross;
    final imgH = cardW * 0.85;
    final listH = imgH + 48;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => RepaintBoundary(
                child: _buildCard(state.items[i], isDark, imgH),
              ),
              childCount: state.items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              mainAxisExtent: widget.type == ViewAllType.materials ? 160 : listH,
            ),
          ),
        ),
        if (state.isPaginating)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildCard(dynamic item, bool isDark, double imgH) {
    if (item is CombinationItem) {
      return ViewAllCombinationCard(item: item, isDark: isDark, imgH: imgH);
    }
    if (item is FurnitureItem) {
      return ViewAllFurnitureCard(item: item, isDark: isDark, imgH: imgH);
    }
    if (item is MaterialListItem) {
      return ViewAllMaterialCard(
        item: item,
        isDark: isDark,
        onTap: () => _onMaterialTap(item),
      );
    }
    return const SizedBox.shrink();
  }

  void _onMaterialTap(MaterialListItem item) {
    final matItem = home.MaterialItem(
      id: item.id,
      name: item.name,
      previewImage: item.previewImage.isEmpty ? null : item.previewImage,
      defaultColor: item.defaultColor == null
          ? null
          : home.MaterialDefaultColor(
              id: item.defaultColor!.id,
              name: item.defaultColor!.name,
              hexCode: item.defaultColor!.hexCode,
              previewImage: item.defaultColor!.previewImage,
            ),
      stats: home.MaterialStats(
        furnitureCount: item.furnitureCount,
        viewCount: item.viewCount,
      ),
    );

    showMaterialFurnitureSheet(
      context: context,
      materialItem: matItem,
      useCase: sl<GetMaterialFurnitureUseCase>(),
      popOnSelect: false,
      onFurnitureSelected: (selected) {
        Navigator.of(context).pushNamed(
          Pages.furnitureDetail,
          arguments: {
            'furnitureId': selected.furniture.id,
            'furnitureMaterialId': selected.furnitureMaterialId,
          },
        );
      },
    );
  }

  Widget _buildError(bool isDark) {
    return AppErrorState(
      onRetry: () => context.read<ViewAllBloc>().add(ViewAllFetched(
          search: _searchController.text.isEmpty
              ? null
              : _searchController.text)),
      isDark: isDark,
    );
  }

  Widget _buildEmpty(bool isDark) {
    return AppEmptyState(
      icon: Icons.inbox_rounded,
      title: AppTexts.searchNoResults.tr(),
      isDark: isDark,
    );
  }
}
