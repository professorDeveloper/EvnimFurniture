import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/view_history_service.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';
import '../bloc/detail_bloc.dart';

const _kGold = Color(0xFFBFA06A);
const _kStar = Color(0xFFFFB800);
const _kDark = Color(0xFF2C2118);
const _kImageH = 340.0;

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.furnitureId,
    required this.furnitureMaterialId,
  });

  final String furnitureId;
  final String furnitureMaterialId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DetailBloc>()
        ..add(DetailFetchRequested(furnitureMaterialId: furnitureMaterialId)),
      child: _DetailView(
        furnitureId: furnitureId,
        initialMaterialId: furnitureMaterialId,
      ),
    );
  }
}


class _DetailView extends StatefulWidget {
  const _DetailView({
    required this.furnitureId,
    required this.initialMaterialId,
  });

  final String furnitureId;
  final String initialMaterialId;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView>
    with TickerProviderStateMixin {
  late String _currentMaterialId;

  final _pageCtrl = PageController();
  final _scrollCtrl = ScrollController();

  int _page = 0;
  int _colorIdx = 0;
  bool _isFav = false;
  bool _modelViewerMounted = false;
  bool _showing3d = false;
  bool _isCollapsed = false;
  bool _isFirstView = false;
  int? _myRating;
  double _overscroll = 0;

  String? _loadedTitle;

  late final AnimationController _contentAnim;
  late final AnimationController _firstViewBadgeAnim;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _badgeScale;

  final _viewHistory = sl<ViewHistoryService>();

  @override
  void initState() {
    super.initState();
    _currentMaterialId = widget.initialMaterialId;

    _isFirstView = !_viewHistory.hasViewed(widget.furnitureId);
    _viewHistory.recordView(widget.furnitureId);

    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _contentFade = CurvedAnimation(
      parent: _contentAnim,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnim,
      curve: Curves.easeOutCubic,
    ));

    _firstViewBadgeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _firstViewBadgeAnim,
      curve: Curves.elasticOut,
    );

    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    _contentAnim.dispose();
    _firstViewBadgeAnim.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;

    final collapsed =
        offset > (_kImageH + MediaQuery.of(context).padding.top - 56);
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }

    if (_showing3d) {
      final over = offset < 0 ? (-offset).clamp(0.0, 180.0) : 0.0;
      if (over != _overscroll) setState(() => _overscroll = over);
    } else if (_overscroll != 0) {
      setState(() => _overscroll = 0);
    }
  }

  void _changeMaterial(String id) {
    if (id == _currentMaterialId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentMaterialId = id;
      _colorIdx = 0;
      _page = 0;
      _showing3d = false;
      _contentAnim.reset();
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
    context
        .read<DetailBloc>()
        .add(DetailFetchRequested(furnitureMaterialId: id));
  }

  void _changeColor(int idx) {
    if (idx == _colorIdx) return;
    HapticFeedback.selectionClick();
    setState(() {
      _colorIdx = idx;
      _page = 0;
    });
    if (_pageCtrl.hasClients) _pageCtrl.jumpToPage(0);
  }

  List<String> _pageItems(FurnitureMaterialColorsResponse data) {
    final colors = data.colors;
    if (colors.isNotEmpty && _colorIdx < colors.length) {
      final combo = colors[_colorIdx].comboImages;
      if (combo.isNotEmpty) return combo.where((e) => e.isNotEmpty).toList();
    }
    return data.furniture.allImages;
  }

  void _toggle3d(FurnitureMaterialColorsResponse data) {
    if (!data.has3dModel) return;
    HapticFeedback.selectionClick();
    setState(() {
      _showing3d = !_showing3d;
      if (_showing3d) _modelViewerMounted = true;
    });
  }

  Future<void> _openFullscreen3d(
    String modelUrl,
    String title,
    List<FurnitureMaterialColor> colors,
  ) async {
    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => _FullScreen3d(
          modelUrl: modelUrl,
          title: title,
          colors: colors,
          initialColorIdx: _colorIdx,
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutExpo,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: anim,
              curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
              reverseCurve: Curves.easeIn,
            ),
            child: ScaleTransition(
              scale: Tween(begin: 0.88, end: 1.0).animate(curved),
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
      ),
    );
    if (result != null && mounted) _changeColor(result);
  }

  void _openImageGallery(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => _FullScreenGallery(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(curved),
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
      ),
    );
  }


  void _onRate(int stars) {
    HapticFeedback.mediumImpact();
    setState(() => _myRating = stars);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<DetailBloc, DetailState>(
        listener: (context, state) {
          if (state is DetailLoaded) {
            _myRating ??= state.data.myRating;
            _loadedTitle = state.data.furniture.name;
            if (!_contentAnim.isCompleted) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _contentAnim.forward());
            }
            if (_isFirstView && !_firstViewBadgeAnim.isCompleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Future.delayed(const Duration(milliseconds: 300),
                          () => _firstViewBadgeAnim.forward()));
            }
          }
        },
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          if (state is DetailError) {
            return _ErrorView(onBack: () => Navigator.of(context).pop());
          }
          final data = (state as DetailLoaded).data;
          return _buildBody(context, data, isDark);
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, FurnitureMaterialColorsResponse data, bool isDark) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final safeBtm = mq.padding.bottom;
    final fullH = _kImageH + safeTop + _overscroll;

    final colors = data.colors;
    final colorIdx =
    _colorIdx.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
    final items = _pageItems(data);

    return Stack(
      children: [
        NotificationListener<OverscrollNotification>(
          onNotification: (n) {
            if (_showing3d && n.overscroll < 0) {
              final over = (-n.overscroll).clamp(0.0, 180.0);
              if (over != _overscroll) setState(() => _overscroll = over);
              return true;
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 60),
                  height: fullH,
                  child: _ImagePane(
                    items: items,
                    pageCtrl: _pageCtrl,
                    page: _page,
                    safeTop: safeTop,
                    showing3d: _showing3d,
                    modelViewerMounted: _modelViewerMounted,
                    has3dModel: data.has3dModel,
                    modelFile: data.modelFile,
                    onPageChanged: (p) => setState(() => _page = p),
                    on360Toggle: () => _toggle3d(data),
                    onFullscreen: () => _openFullscreen3d(
                      data.modelFile!,
                      data.furniture.name,
                      data.colors,
                    ),
                    overscroll: _overscroll,
                    onImageTap: (idx) => _openImageGallery(items, idx),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: _ContentSection(
                      data: data,
                      currentMaterialId: _currentMaterialId,
                      colors: colors,
                      colorIdx: colorIdx,
                      myRating: _myRating,
                      isFirstView: _isFirstView,
                      badgeScale: _badgeScale,
                      isDark: isDark,
                      onMaterialChanged: _changeMaterial,
                      onColorChanged: _changeColor,
                      onRate: _onRate,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                  padding: EdgeInsets.only(bottom: safeBtm + 40)),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _FloatingHeader(
            isCollapsed: _isCollapsed,
            safeTop: safeTop,
            title: _loadedTitle ?? '',
            isFav: _isFav,
            isDark: isDark,
            onBack: () => Navigator.of(context).pop(),
            onFav: () {
              HapticFeedback.lightImpact();
              setState(() => _isFav = !_isFav);
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image pane
// ─────────────────────────────────────────────────────────────────────────────

class _ImagePane extends StatelessWidget {
  const _ImagePane({
    required this.items,
    required this.pageCtrl,
    required this.page,
    required this.safeTop,
    required this.showing3d,
    required this.modelViewerMounted,
    required this.has3dModel,
    required this.modelFile,
    required this.onPageChanged,
    required this.on360Toggle,
    required this.onFullscreen,
    required this.overscroll,
    this.onImageTap,
  });

  final List<String> items;
  final PageController pageCtrl;
  final int page;
  final double safeTop;
  final bool showing3d;
  final bool modelViewerMounted;
  final bool has3dModel;
  final String? modelFile;
  final ValueChanged<int> onPageChanged;
  final VoidCallback on360Toggle;
  final VoidCallback onFullscreen;
  final double overscroll;
  final ValueChanged<int>? onImageTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: showing3d,
          child: PageView.builder(
            controller: pageCtrl,
            physics: const BouncingScrollPhysics(),
            itemCount: items.isEmpty ? 1 : items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) => items.isEmpty
                ? const _ImgPlaceholder()
                : GestureDetector(
              onTap: () => onImageTap?.call(i),
              child: _PageImage(url: items[i]),
            ),
          ),
        ),
        if (modelViewerMounted && has3dModel)
          Offstage(
            offstage: !showing3d,
            child: _KeepAliveModelViewer(
              key: ValueKey(modelFile),
              modelUrl: modelFile!,
            ),
          ),
        if (!showing3d)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    stops: const [0.38, 1.0],
                  ),
                ),
              ),
            ),
          ),
        if (!showing3d && items.length > 1)
          Positioned(
            bottom: 78,
            left: 0,
            right: 0,
            child: _PageDots(current: page, count: items.length),
          ),
        if (!showing3d)
          Positioned(
            bottom: 38,
            left: 14,
            child: _CountPill(current: page + 1, total: items.length),
          ),
        Positioned(
          bottom: 54,
          right: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showing3d)
                _ViewToggleBtn(
                  icon: Icons.photo_library_rounded,
                  label: AppTexts.detailPhotos.tr(),
                  onTap: on360Toggle,
                ),
              if (showing3d) const SizedBox(width: 8),
              if (showing3d)
                _ViewToggleBtn(
                  icon: Icons.open_in_full_rounded,
                  label: AppTexts.detailExpand.tr(),
                  onTap: onFullscreen,
                ),
              if (!showing3d && has3dModel) ...[
                _ViewToggleBtn(
                  icon: Icons.view_in_ar_rounded,
                  label: 'AR',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _ViewToggleBtn(
                  icon: Icons.rotate_90_degrees_ccw_rounded,
                  label: '360°',
                  onTap: on360Toggle,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
          ),
        ),
        if (showing3d && overscroll > 10)
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: (overscroll - 10) / 60,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppTexts.detailPullDownToExpand.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Pill-shaped button for image pane controls (AR / 360° / Photos / Expand)
class _ViewToggleBtn extends StatelessWidget {
  const _ViewToggleBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.1,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _CountPill extends StatelessWidget {
  const _CountPill({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$current / $total',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating header
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingHeader extends StatelessWidget {
  const _FloatingHeader({
    required this.isCollapsed,
    required this.safeTop,
    required this.title,
    required this.isFav,
    required this.isDark,
    required this.onBack,
    required this.onFav,
  });

  final bool isCollapsed;
  final double safeTop;
  final String title;
  final bool isFav;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onFav;

  @override
  Widget build(BuildContext context) {
    final collapsedBg =
        isDark ? AppColors.darkSurface : Colors.white;
    final titleColor =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isCollapsed ? collapsedBg : Colors.transparent,
        boxShadow: isCollapsed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      height: safeTop + 52,
      padding: EdgeInsets.only(top: safeTop, left: 6, right: 6),
      child: Row(
        children: [
          _HBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            collapsed: isCollapsed,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _LikeBtn(
            isFav: isFav,
            onTap: onFav,
            collapsed: isCollapsed,
          ),
        ],
      ),
    );
  }
}

class _HBtn extends StatelessWidget {
  const _HBtn({
    required this.icon,
    required this.onTap,
    required this.collapsed,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 42,
        height: 42,
        child: collapsed
            ? Icon(icon, size: 20, color: AppColors.onSurface)
            : ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Like button (animated heart)
// ─────────────────────────────────────────────────────────────────────────────

class _LikeBtn extends StatefulWidget {
  const _LikeBtn({
    required this.isFav,
    required this.onTap,
    required this.collapsed,
  });
  final bool isFav;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  State<_LikeBtn> createState() => _LikeBtnState();
}

class _LikeBtnState extends State<_LikeBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.35)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: 1.35, end: 0.85)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 0.85, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_LikeBtn old) {
    super.didUpdateWidget(old);
    if (widget.isFav != old.isFav && widget.isFav) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isFav
        ? const Color(0xFFE53935)
        : (widget.collapsed ? AppColors.onSurface : Colors.white);

    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Icon(
        widget.isFav
            ? Icons.favorite_rounded
            : Icons.favorite_border_rounded,
        key: ValueKey(widget.isFav),
        size: 21,
        color: iconColor,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 42,
        height: 42,
        child: widget.collapsed
            ? Center(child: ScaleTransition(scale: _scale, child: icon))
            : ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: widget.isFav
                          ? const Color(0xFFE53935).withValues(alpha: 0.28)
                          : Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isFav
                            ? const Color(0xFFE53935).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.45),
                        width: 0.8,
                      ),
                    ),
                    child: Center(
                      child: ScaleTransition(scale: _scale, child: icon),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────

class _KeepAliveModelViewer extends StatefulWidget {
  const _KeepAliveModelViewer({super.key, required this.modelUrl});
  final String modelUrl;

  @override
  State<_KeepAliveModelViewer> createState() =>
      _KeepAliveModelViewerState();
}

class _KeepAliveModelViewerState extends State<_KeepAliveModelViewer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ModelViewer(
      src: widget.modelUrl,
      ar: false,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: const Color(0xFF0F0F0F),
    );
  }
}

class _FullScreen3d extends StatefulWidget {
  const _FullScreen3d({
    required this.modelUrl,
    required this.title,
    required this.colors,
    required this.initialColorIdx,
  });
  final String modelUrl;
  final String title;
  final List<FurnitureMaterialColor> colors;
  final int initialColorIdx;

  @override
  State<_FullScreen3d> createState() => _FullScreen3dState();
}

class _FullScreen3dState extends State<_FullScreen3d> {
  late int _colorIdx;
  final _colorScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _colorIdx = widget.initialColorIdx;
  }

  @override
  void dispose() {
    _colorScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBtm = MediaQuery.of(context).padding.bottom;
    final hasColors = widget.colors.isNotEmpty;

    return PopScope(
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                src: widget.modelUrl,
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: const Color(0xFF0F0F0F),
              ),
            ),

            // ── Top bar ─────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: safeTop + 56,
                padding: EdgeInsets.only(top: safeTop, left: 8, right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(_colorIdx),
                      behavior: HitTestBehavior.opaque,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom color picker ──────────────────────────────
            if (hasColors)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 0.8,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 14,
                        bottom: safeBtm + 14,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppTexts.detailColor.tr(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.55),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              controller: _colorScroll,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.colors.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final c = widget.colors[i];
                                final sel = i == _colorIdx;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _colorIdx = i);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: sel ? 44 : 38,
                                        height: sel ? 44 : 38,
                                        padding: EdgeInsets.all(sel ? 3 : 0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: sel
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: c.color,
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.15),
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 9,
                                          color: sel
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.5),
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fullscreen image gallery
// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });
  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBtm = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Zoomable page view ───────────────────────────────
          PageView.builder(
            controller: _ctrl,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: (p) => setState(() => _current = p),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.images[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white38,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: Colors.white24, size: 48),
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: safeTop + 56,
              padding: EdgeInsets.only(top: safeTop, left: 8, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_current + 1} / ${widget.images.length}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom dots ──────────────────────────────────────
          if (widget.images.length > 1)
            Positioned(
              bottom: safeBtm + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}



class _MatOpt {
  const _MatOpt({required this.id, required this.name, this.image});
  final String id;
  final String name;
  final String? image;
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.data,
    required this.currentMaterialId,
    required this.colors,
    required this.colorIdx,
    required this.myRating,
    required this.isFirstView,
    required this.badgeScale,
    required this.isDark,
    required this.onMaterialChanged,
    required this.onColorChanged,
    required this.onRate,
  });

  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
  final List<FurnitureMaterialColor> colors;
  final int colorIdx;
  final int? myRating;
  final bool isFirstView;
  final Animation<double> badgeScale;
  final bool isDark;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final furniture = data.furniture;
    final material = data.material;
    final hasMatInfo = !material.isEmpty;
    final selectedColor = colors.isNotEmpty ? colors[colorIdx] : null;

    final allMaterials = <_MatOpt>[
      if (hasMatInfo)
        _MatOpt(
            id: currentMaterialId,
            name: material.name,
            image: material.firstImage),
      ...data.otherMaterials.map(
            (m) => _MatOpt(
            id: m.furnitureMaterialId,
            name: m.materialName,
            image: m.previewImage),
      ),
    ];

    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        furniture.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (isFirstView)
                      ScaleTransition(
                        scale: badgeScale,
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _kGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _kGold.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            AppTexts.detailFirstLook.tr(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kGold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (hasMatInfo) ...[
                  const SizedBox(height: 3),
                  Text(
                    material.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: textSub,
                    ),
                  ),
                ],
                if (furniture.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: furniture.tags
                        .take(4)
                        .map((t) => _TagChip(label: t))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                _StatsRow(
                  stats: furniture.stats,
                  myRating: myRating,
                  onRate: onRate,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                    label: Text(
                      AppTexts.detailTryInRoom.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (allMaterials.isNotEmpty) ...[
            const _Div(),
            _SectionHdr(label: AppTexts.detailMaterial.tr()),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: allMaterials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final opt = allMaterials[i];
                  final sel = opt.id == currentMaterialId;
                  return _MatCard(
                    opt: opt,
                    isSelected: sel,
                    onTap: () => onMaterialChanged(opt.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (colors.isNotEmpty) ...[
            const _Div(),
            _SectionHdr(label: AppTexts.detailColor.tr()),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _ColorSwatch(
                  color: colors[i],
                  isSelected: i == colorIdx,
                  onTap: () => onColorChanged(i),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (hasMatInfo || selectedColor != null) ...[
            const _Div(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasMatInfo)
                    _InfoPair(
                        label: AppTexts.detailMaterial.tr(),
                        value: material.name),
                  if (selectedColor != null) ...[
                    if (hasMatInfo) const SizedBox(height: 12),
                    _InfoPair(
                        label: AppTexts.detailColor.tr(),
                        value: selectedColor.name),
                  ],
                  if (hasMatInfo &&
                      (material.description?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    _SubLabel(text: AppTexts.detailCareInstructions.tr()),
                    const SizedBox(height: 5),
                    Text(
                      material.description!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.onSurface,
                        height: 1.65,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (furniture.description?.isNotEmpty ?? false) ...[
            const _Div(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubLabel(text: AppTexts.detailAboutThisPiece.tr()),
                  const SizedBox(height: 5),
                  Text(
                    furniture.description!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.65,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.stats,
    required this.myRating,
    required this.onRate,
  });

  final FMCStats stats;
  final int? myRating;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: _kStar, size: 16),
            const SizedBox(width: 4),
            Text(
              stats.avgRating.toStringAsFixed(1),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 5),
            _Dot(),
            const SizedBox(width: 5),
            Text(
              '${stats.ratingCount} reviews',
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppColors.grey500),
            ),
            if (stats.viewCount > 0) ...[
              const SizedBox(width: 5),
              _Dot(),
              const SizedBox(width: 5),
              Text(
                '${stats.viewCount} views',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              myRating != null
                  ? '${AppTexts.detailYourRating.tr()}:'
                  : '${AppTexts.detailRate.tr()}:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              final on = myRating != null && i < myRating!;
              return GestureDetector(
                onTap: () => onRate(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      on ? Icons.star_rounded : Icons.star_outline_rounded,
                      key: ValueKey(on),
                      color: on ? _kStar : AppColors.grey300,
                      size: 26,
                    ),
                  ),
                ),
              );
            }),
            if (myRating != null) ...[
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _rLabel(myRating!),
                  key: ValueKey(myRating),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kStar,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _rLabel(int r) => switch (r) {
    1 => AppTexts.detailRatingPoor.tr(),
    2 => AppTexts.detailRatingFair.tr(),
    3 => AppTexts.detailRatingGood.tr(),
    4 => AppTexts.detailRatingVeryGood.tr(),
    5 => AppTexts.detailRatingExcellent.tr(),
    _ => '',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Material card
// ─────────────────────────────────────────────────────────────────────────────

class _MatCard extends StatelessWidget {
  const _MatCard({
    required this.opt,
    required this.isSelected,
    required this.onTap,
  });

  final _MatOpt opt;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 84,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected
                      ? _kDark.withValues(alpha: 0.65)
                      : AppColors.grey200,
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: _kDark.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.5),
                child: opt.image?.isNotEmpty == true
                    ? CachedNetworkImage(
                  imageUrl: opt.image!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                  const ColoredBox(color: AppColors.grey100),
                  errorWidget: (_, __, ___) => const _MatPh(),
                )
                    : const _MatPh(),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              opt.name,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _kDark : AppColors.grey600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color swatch
// ─────────────────────────────────────────────────────────────────────────────

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final FurnitureMaterialColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              padding: EdgeInsets.all(isSelected ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _kDark : Colors.transparent,
                  width: isSelected ? 1.8 : 0,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.color,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.07),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              color.name,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? _kDark : AppColors.grey500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Misc small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PageImage extends StatelessWidget {
  const _PageImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImgPlaceholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(color: AppColors.grey100),
      errorWidget: (_, __, ___) => const _ImgPlaceholder(),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: 3,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.grey400,
    ),
  );
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: AppColors.grey100, height: 1),
    );
  }
}

class _SectionHdr extends StatelessWidget {
  const _SectionHdr({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: AppColors.grey500,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubLabel(text: label),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.chair_outlined,
            size: 64, color: AppColors.grey300),
      ),
    );
  }
}

class _MatPh extends StatelessWidget {
  const _MatPh();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.texture_rounded,
            size: 22, color: AppColors.grey300),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        const Positioned.fill(
            child: ColoredBox(color: AppColors.grey100)),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
        Positioned(
          top: top + 8,
          left: 12,
          child: _HBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            collapsed: false,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 44, color: AppColors.grey300),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: Text(
              'Orqaga',
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
}