import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../data/model/material_furniture_response.dart';
import '../../domain/model/material_item.dart';
import '../../domain/usecases/get_materials_furniture_usecase.dart';
import 'zig_zag_clipper.dart';

void showMaterialFurnitureSheet({
  required BuildContext context,
  required MaterialItem materialItem,
  required GetMaterialFurnitureUseCase useCase,
  required void Function(MaterialFurnitureItem selectedItem) onFurnitureSelected,
  // When false, the sheet stays on the stack so the caller can push detail
  // on top of it (back-from-detail returns to the sheet, not the caller).
  bool popOnSelect = true,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => _MaterialFurniturePage(
        materialItem: materialItem,
        useCase: useCase,
        onFurnitureSelected: (item) {
          if (popOnSelect) Navigator.of(context).pop();
          onFurnitureSelected(item);
        },
      ),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 320),
    ),
  );
}

class _MaterialFurniturePage extends StatefulWidget {
  const _MaterialFurniturePage({
    required this.materialItem,
    required this.useCase,
    required this.onFurnitureSelected,
  });

  final MaterialItem materialItem;
  final GetMaterialFurnitureUseCase useCase;
  final void Function(MaterialFurnitureItem) onFurnitureSelected;

  @override
  State<_MaterialFurniturePage> createState() => _MaterialFurniturePageState();
}

class _MaterialFurniturePageState extends State<_MaterialFurniturePage>
    with SingleTickerProviderStateMixin {
  late Future<MaterialFurnitureResponse> _future;
  List<MaterialFurnitureItem> _allItems = [];
  List<MaterialFurnitureItem> _filteredItems = [];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _future = widget.useCase(materialId: widget.materialItem.id);

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

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems = query.isEmpty
          ? List.of(_allItems)
          : _allItems
          .where((e) => e.furniture.name.toLowerCase().contains(query))
          .toList();
    });
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
      if (mounted) {
        setState(() {
          _isSearching = false;
          _filteredItems = List.of(_allItems);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.white;
    final appBarBg =
    isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF5F5F5);
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;
    final divider = isDark ? AppColors.darkDivider : AppColors.grey200;
    final item = widget.materialItem;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return ClipPath(
                clipper: _isSearching
                    ? null
                    : const ZigZagClipper(zigHeight: 10.0, count: 16),
                child: Container(
                  color: _isSearching
                      ? (isDark ? AppColors.darkSurface : AppColors.white)
                      : appBarBg,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ── Default row ──────────────────────
                            FadeTransition(
                              opacity: ReverseAnimation(_fadeAnim),
                              child: IgnorePointer(
                                ignoring: _isSearching,
                                child: Row(
                                  children: [
                                    _AppBarIconButton(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      tooltip: 'Back',
                                      isDark: isDark,
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    const SizedBox(width: 4),
                                    if (item.firstImage != null) ...[
                                      _ThumbnailAvatar(
                                        url: item.firstImage!,
                                        isDark: isDark,
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: textMain,
                                              letterSpacing: -0.3,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            AppTexts
                                                .materialSheetSelectFurniture
                                                .tr(),
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: textSub,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _AppBarIconButton(
                                      icon: Icons.search_rounded,
                                      tooltip: 'Search',
                                      isDark: isDark,
                                      onPressed: _openSearch,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ── Search row ───────────────────────
                            FadeTransition(
                              opacity: _fadeAnim,
                              child: SlideTransition(
                                position: _slideAnim,
                                child: IgnorePointer(
                                  ignoring: !_isSearching,
                                  child: Row(
                                    children: [
                                      _AppBarIconButton(
                                        icon:
                                        Icons.arrow_back_ios_new_rounded,
                                        tooltip: 'Close search',
                                        isDark: isDark,
                                        onPressed: _closeSearch,
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
                ),
              );
            },
          ),

          Divider(height: 1, color: divider),

          // ── Grid ──────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<MaterialFurnitureResponse>(
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
                  return _buildError(snapshot.error.toString(), isDark);
                }
                final data = snapshot.data!;
                if (data.furniture.isEmpty) {
                  return _buildEmpty(isDark);
                }

                if (_allItems.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _allItems = data.furniture;
                        _filteredItems = List.of(_allItems);
                      });
                    }
                  });
                }

                final query = _searchController.text;
                final displayItems =
                query.isNotEmpty ? _filteredItems : data.furniture;

                if (displayItems.isEmpty && query.isNotEmpty) {
                  return _buildNoResults(isDark);
                }

                return _buildGrid(displayItems, isDark);
              },
            ),
          ),
        ],
      ),
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
          const SizedBox(height: 12),
          Text(AppTexts.materialSheetLoadError.tr(),
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.onSurface)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() =>
            _future =
                widget.useCase(materialId: widget.materialItem.id)),
            child: Text(AppTexts.materialSheetRetry.tr(),
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
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
          Icon(Icons.inbox_rounded,
              size: 44,
              color: isDark ? AppColors.grey600 : AppColors.grey300),
          const SizedBox(height: 12),
          Text(AppTexts.materialSheetEmpty.tr(),
              style:
              GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 44,
              color: isDark ? AppColors.grey600 : AppColors.grey300),
          const SizedBox(height: 12),
          Text(AppTexts.searchNoResults.tr(),
              style:
              GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<MaterialFurnitureItem> items, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _FurnitureGridCard(
        item: items[i],
        isDark: isDark,
        onTap: () {
          HapticFeedback.lightImpact();
          debugPrint('Selected Furniture: ${items[i]}');
          widget.onFurnitureSelected(items[i]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar IconButton
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
    isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final Color splashColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.onSurface.withValues(alpha: 0.07);

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: iconColor),
      style: IconButton.styleFrom(
        backgroundColor:
        isDark ? AppColors.darkSurface : AppColors.white,
        fixedSize: const Size(38, 38),
        shape: const CircleBorder(),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return splashColor;
          if (states.contains(WidgetState.hovered)) {
            return splashColor.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Field
// ─────────────────────────────────────────────────────────────────────────────

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
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;

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
          fontSize: 14,
          color: textMain,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: AppTexts.searchHint.tr(),
          hintStyle: GoogleFonts.dmSans(
            fontSize: 14,
            color: textSub,
            height: 1.0,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: textSub),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 36, minHeight: 40),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: controller.clear,
                    child: Icon(Icons.close_rounded,
                        size: 16, color: textSub),
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

// ─────────────────────────────────────────────────────────────────────────────
// Thumbnail avatar in appbar
// ─────────────────────────────────────────────────────────────────────────────

class _ThumbnailAvatar extends StatelessWidget {
  const _ThumbnailAvatar({required this.url, required this.isDark});

  final String url;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 38,
        height: 38,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => ColoredBox(
            color: isDark ? AppColors.darkSurface : AppColors.grey200,
          ),
          errorWidget: (_, __, ___) => ColoredBox(
            color: isDark ? AppColors.darkSurface : AppColors.grey200,
            child: const Icon(Icons.texture_rounded,
                size: 18, color: AppColors.grey400),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Furniture card
// ─────────────────────────────────────────────────────────────────────────────

class _FurnitureGridCard extends StatelessWidget {
  const _FurnitureGridCard({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final MaterialFurnitureItem item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurfaceVariant : AppColors.grey100;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;

    return GestureDetector(
      onTap: onTap,
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
                  _buildImage(surface),
                  if (item.furniture.avgRating > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 9, color: Color(0xFFFFD700)),
                            const SizedBox(width: 2),
                            Text(
                              item.furniture.avgRating.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
          ),
          if (item.defaultColor != null) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.defaultColor!.color,
                      border:
                      Border.all(color: AppColors.grey300, width: 0.8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.defaultColor!.name,
                      style: GoogleFonts.dmSans(
                          fontSize: 10, color: textSub, height: 1.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(Color bg) {
    final url = item.furniture.thumbnailImage;
    if (url == null || url.isEmpty || url == 'string') {
      return Center(
          child: Icon(Icons.chair_outlined,
              size: 36, color: AppColors.grey300));
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(
          child: Icon(Icons.chair_outlined,
              size: 36, color: AppColors.grey300)),
    );
  }
}