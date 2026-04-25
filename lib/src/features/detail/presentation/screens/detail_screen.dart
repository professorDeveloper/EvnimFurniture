import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/services/view_history_service.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';
import '../bloc/detail_bloc.dart';
import 'ai_try_room_screen.dart';
import 'ar_viewer_screen.dart';
import 'native_ar_screen.dart';

part 'widgets/detail_image_pane.dart';
part 'widgets/detail_fullscreen.dart';
part 'widgets/detail_header.dart';
part 'widgets/detail_content.dart';
part 'widgets/detail_common_widgets.dart';
part 'widgets/detail_dialogs.dart';

const _kGold = AppColors.secondary;
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

class _DetailViewState extends State<_DetailView> {
  late String _currentMaterialId;

  final _pageCtrl = PageController();
  final _scrollCtrl = ScrollController();

  int _page = 0;
  int _colorIdx = 0;
  bool _isFav = false;
  bool _isCollapsed = false;
  bool _showing3d = false;
  int? _myRating;
  bool _myRatingFetched = false;
  String? _loadedTitle;

  final _viewHistory = sl<ViewHistoryService>();

  @override
  void initState() {
    super.initState();
    _currentMaterialId = widget.initialMaterialId;
    _viewHistory.recordView(widget.furnitureId);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    final collapsed = offset > (_kImageH - 52.0);
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  void _changeMaterial(String id) {
    if (id == _currentMaterialId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentMaterialId = id;
      _colorIdx = 0;
      _page = 0;
      _showing3d = false;
      _myRating = null;
      _myRatingFetched = false;
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

  void _onRate(int stars) {
    _requireAuth(context, () {
      HapticFeedback.mediumImpact();
      setState(() => _myRating = stars);
      context.read<DetailBloc>().add(DetailRateSubmitted(
            furnitureMaterialId: _currentMaterialId,
            score: stars,
          ));
    });
  }

  List<String> _pageItems(FurnitureMaterialColorsResponse data) {
    final seen = <String>{};
    final result = <String>[];
    void add(String img) {
      if (img.isNotEmpty && seen.add(img)) result.add(img);
    }

    final colors = data.colors;
    if (colors.isNotEmpty && _colorIdx < colors.length) {
      for (final img in colors[_colorIdx].comboImages) {
        add(img);
      }
    }
    for (final img in data.furniture.allImages) {
      add(img);
    }
    return result;
  }

  void _toggle3d() {
    HapticFeedback.selectionClick();
    setState(() => _showing3d = !_showing3d);
  }

  Future<void> _openFullscreen3d(
    String modelUrl,
    String title,
    List<FurnitureMaterialColor> colors,
  ) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ArViewerScreen(
          modelUrl: modelUrl,
          title: title,
          colors: colors,
          initialColorIdx: _colorIdx,
        ),
      ),
    );
    if (result != null && mounted) _changeColor(result);
  }

  void _launchAR(String modelUrl, String title) {
    debugPrint('AR LAUNCH: modelUrl=$modelUrl, title=$title');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NativeArScreen(
          modelUrl: modelUrl,
          title: title,
        ),
      ),
    );
  }

  void _openImageGallery(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenGallery(images: images, initialIndex: initialIndex),
      ),
    );
  }

  void _requireAuth(BuildContext ctx, VoidCallback action) {
    if (FirebaseAuth.instance.currentUser != null) {
      action();
      return;
    }
    Navigator.of(ctx).pushNamed(Pages.login);
  }

  void _onTryInRoom(String furnitureUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiTryRoomScreen(furnitureImageUrl: furnitureUrl),
      ),
    );
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
            setState(() {
              _myRating = state.myRating ?? state.data.myRating ?? _myRating;
              _isFav = state.isFavorite;
              _loadedTitle = state.data.furniture.name;
            });
            if (_myRating == null &&
                !_myRatingFetched &&
                FirebaseAuth.instance.currentUser != null) {
              _myRatingFetched = true;
              context.read<DetailBloc>().add(
                    DetailMyRatingRequested(
                        furnitureMaterialId: state.currentMaterialId),
                  );
            }
          }
        },
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          if (state is DetailError) {
            return _ErrorView(
              onBack: () => Navigator.of(context).pop(),
              onRetry: () => context.read<DetailBloc>().add(
                DetailFetchRequested(furnitureMaterialId: _currentMaterialId),
              ),
            );
          }
          final data = switch (state) {
            DetailLoaded s => s.data,
            DetailAiProcessing s => s.data,
            DetailAiSuccess s => s.data,
            DetailAiError s => s.data,
            _ => null,
          };
          if (data == null) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          return _buildBody(context, data, isDark);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FurnitureMaterialColorsResponse data,
    bool isDark,
  ) {
    final safeBtm = MediaQuery.of(context).padding.bottom;
    final colors = data.colors;
    final colorIdx =
        _colorIdx.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
    final items = _pageItems(data);
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverAppBar(
          primary: true,
          expandedHeight: _kImageH,
          toolbarHeight: 52,
          pinned: true,
          floating: false,
          backgroundColor: bg,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leadingWidth: 52,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _HBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
                collapsed: _isCollapsed,
              ),
            ),
          ),
          title: AnimatedOpacity(
            opacity: _isCollapsed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Text(
              _loadedTitle ?? '',
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _LikeBtn(
                isFav: _isFav,
                onTap: () => _requireAuth(context, () {
                  HapticFeedback.lightImpact();
                  context.read<DetailBloc>().add(
                        DetailFavoriteToggled(
                            furnitureMaterialId: _currentMaterialId),
                      );
                }),
                collapsed: _isCollapsed,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: RepaintBoundary(
              child: _ImagePane(
                items: items,
                pageCtrl: _pageCtrl,
                page: _page,
                showing3d: _showing3d,
                has3dModel: data.has3dModel,
                modelFile: data.modelFile,
                onPageChanged: (p) => setState(() => _page = p),
                on360: data.has3dModel ? _toggle3d : null,
                onAr: data.has3dModel
                    ? () => _launchAR(
                          data.modelFile!,
                          data.furniture.name,
                        )
                    : null,
                onExpand: (data.has3dModel && _showing3d)
                    ? () => _openFullscreen3d(
                          data.modelFile!,
                          data.furniture.name,
                          data.colors,
                        )
                    : null,
                onImageTap: (idx) => _openImageGallery(items, idx),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _ContentSection(
            data: data,
            currentMaterialId: _currentMaterialId,
            colors: colors,
            colorIdx: colorIdx,
            myRating: _myRating,
            isDark: isDark,
            onMaterialChanged: _changeMaterial,
            onColorChanged: _changeColor,
            onRate: _onRate,
            onTryInRoom: () {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.of(context).pushNamed(Pages.login);
                return;
              }
              final idx =
                  _colorIdx.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
              _onTryInRoom(
                colors.isNotEmpty ? (colors[idx].firstComboImage ?? '') : '',
              );
            },
            onImageTap: (idx) => _openImageGallery(data.furniture.images, idx),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: safeBtm + 40)),
      ],
    );
  }
}
