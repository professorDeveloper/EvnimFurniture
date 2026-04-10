import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/pages.dart';
import '../../../home/domain/model/material_item.dart' as home;
import '../../../home/domain/usecases/get_materials_furniture_usecase.dart';
import '../../../home/presentation/widgets/material_furnitures_sheet.dart';
import '../../data/model/material_item.dart';
import '../bloc/materials_bloc.dart';
import '../widget/material_grid.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MaterialsBloc>().add(MaterialsFetched());
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
      context.read<MaterialsBloc>().add(MaterialsNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
            _buildHeader(isDark, searchBg, hintColor, textMain),
            Expanded(
              child: BlocBuilder<MaterialsBloc, MaterialsState>(
                builder: (context, state) {
                  if (state is MaterialsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (state is MaterialsFailure) {
                    return _buildError(state.message, isDark);
                  }
                  if (state is MaterialsLoaded) {
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
      Color searchBg,
      Color hintColor,
      Color textMain,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.materialsTitle.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textMain,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => context
                  .read<MaterialsBloc>()
                  .add(MaterialsSearchChanged(query: q)),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
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
                                .read<MaterialsBloc>()
                                .add(MaterialsSearchChanged(query: ''));
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
        ],
      ),
    );
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

  Widget _buildGrid(MaterialsLoaded state, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width >= 600 ? 4 : 3;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (_, i) => MaterialGridCard(
                item: state.items[i],
                isDark: isDark,
                index: i,
                onTap: () => _onMaterialTap(state.items[i]),
              ),
              childCount: state.items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              mainAxisExtent: 160,
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
        if (!state.hasMore && state.items.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  AppTexts.allLoaded.tr(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.grey400,
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildError(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 44,
              color: isDark ? AppColors.grey600 : AppColors.grey300),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<MaterialsBloc>().add(
              MaterialsFetched(
                search: _searchController.text.isEmpty
                    ? null
                    : _searchController.text,
              ),
            ),
            child: Text(
              AppTexts.materialSheetRetry.tr(),
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.texture_rounded,
              size: 44,
              color: isDark ? AppColors.grey600 : AppColors.grey300),
          const SizedBox(height: 12),
          Text(
            AppTexts.materialSheetEmpty.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}