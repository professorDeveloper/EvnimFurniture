import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/pages.dart';
import '../../domain/model/category_model.dart';

class CategoriesViewAllScreen extends StatefulWidget {
  const CategoriesViewAllScreen({super.key});

  @override
  State<CategoriesViewAllScreen> createState() =>
      _CategoriesViewAllScreenState();
}

class _CategoriesViewAllScreenState extends State<CategoriesViewAllScreen> {
  late Future<List<CategoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchCategories();
  }

  Future<List<CategoryItem>> _fetchCategories() async {
    final dio = sl<DioClient>().dio;
    final response = await dio.get('api/categories');
    final raw = response.data;
    List<dynamic> list;
    if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else if (raw is List) {
      list = raw;
    } else {
      list = [];
    }
    return list
        .map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.grey200;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
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
                        AppTexts.categoriesTitle.tr(),
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: divider),
          Expanded(
            child: FutureBuilder<List<CategoryItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return AppErrorState(
                    onRetry: () =>
                        setState(() => _future = _fetchCategories()),
                    isDark: isDark,
                  );
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.inbox_rounded,
                    title: AppTexts.materialSheetEmpty.tr(),
                    isDark: isDark,
                  );
                }
                return _buildGrid(items, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<CategoryItem> items, bool isDark) {
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 180,
      ),
      itemCount: items.length,
      cacheExtent: 200,
      itemBuilder: (_, i) {
        final item = items[i];
        return RepaintBoundary(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pushNamed(
                Pages.categoryFurniture,
                arguments: item,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black
                        .withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 10,
                    spreadRadius: -3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: surface),
                    _buildImage(item, surface),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.furnitureCount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              AppTexts.categoryFurnitureCount.tr(args: ['${item.furnitureCount}']),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildImage(CategoryItem item, Color bg) {
    final url = item.coverImage;
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(Icons.category_outlined, size: 40, color: AppColors.grey300),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 400,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.category_outlined, size: 40, color: AppColors.grey300),
      ),
    );
  }
}
