import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/pages.dart';
import '../../../../core/services/view_history_service.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';
import '../bloc/detail_bloc.dart';

part 'widgets/detail_image_pane.dart';
part 'widgets/detail_fullscreen.dart';
part 'widgets/detail_header.dart';
part 'widgets/detail_content.dart';
part 'widgets/detail_common_widgets.dart';
part 'widgets/detail_dialogs.dart';

const _kGold = Color(0xFFBFA06A);
const _kStar = Color(0xFFFFB800);
const _kDark = Color(0xFF2C2118);
const _kImageH = 340.0;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _onScroll() {
    final offset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    final collapsed =
        offset > (_kImageH + MediaQuery.of(context).padding.top - 56);
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);

    if (_showing3d) {
      final over = offset < 0 ? (-offset).clamp(0.0, 180.0) : 0.0;
      if (over != _overscroll) setState(() => _overscroll = over);
    } else if (_overscroll != 0) {
      setState(() => _overscroll = 0);
    }
  }

  // ── Data mutations ─────────────────────────────────────────────────────────

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
    context.read<DetailBloc>().add(DetailFetchRequested(furnitureMaterialId: id));
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
    HapticFeedback.mediumImpact();
    setState(() => _myRating = stars);
  }

  List<String> _pageItems(FurnitureMaterialColorsResponse data) {
    final colors = data.colors;
    if (colors.isNotEmpty && _colorIdx < colors.length) {
      final combo = colors[_colorIdx].comboImages;
      if (combo.isNotEmpty) return combo.where((e) => e.isNotEmpty).toList();
    }
    return data.furniture.allImages;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

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
        pageBuilder: (_, __, ___) =>
            _FullScreenGallery(images: images, initialIndex: initialIndex),
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

  // ── Auth & AI ──────────────────────────────────────────────────────────────

  void _requireAuth(BuildContext ctx, VoidCallback action) {
    if (FirebaseAuth.instance.currentUser != null) {
      action();
      return;
    }
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthRequiredSheet(
        onLogin: () {
          Navigator.pop(ctx);
          Navigator.of(ctx).pushNamed(Pages.login);
        },
      ),
    );
  }

  Future<void> _onTryInRoom(String furnitureUrl) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source == null || !mounted) return;

    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (picked == null || !mounted) return;

    final cancelToken = dio_pkg.CancelToken();
    bool cancelled = false;

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AiLoadingDialog(
        onCancel: () {
          cancelled = true;
          cancelToken.cancel();
          if (mounted) Navigator.of(context).pop();
        },
      ),
    ));

    try {
      Uint8List furnitureBytes = Uint8List(0);
      if (furnitureUrl.isNotEmpty) {
        final res = await dio_pkg.Dio().get<List<int>>(
          furnitureUrl,
          options: dio_pkg.Options(responseType: dio_pkg.ResponseType.bytes),
        );
        furnitureBytes = Uint8List.fromList(res.data ?? []);
      }

      final formData = dio_pkg.FormData.fromMap({
        'room': await dio_pkg.MultipartFile.fromFile(
          picked.path,
          filename: 'room.jpg',
        ),
        'furniture': dio_pkg.MultipartFile.fromBytes(
          furnitureBytes,
          filename: 'furniture.jpg',
        ),
      });

      final response = await sl<DioClient>().dio.post<Map<String, dynamic>>(
        '/api/ai-image/place-furniture',
        data: formData,
        options: dio_pkg.Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
        ),
        cancelToken: cancelToken,
      );

      if (!mounted || cancelled) return;
      Navigator.of(context).pop();

      final base64Image =
          (response.data?['data']?['image'] as String?) ?? '';

      if (base64Image.isEmpty) {
        _showAiError('Xatolik yuz berdi. Qayta urinib ko\'ring.');
        return;
      }

      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => _AiResultPage(base64Image: base64Image),
      ));
    } on dio_pkg.DioException catch (e) {
      if (dio_pkg.CancelToken.isCancel(e) || cancelled) return;
      if (!mounted) return;
      Navigator.of(context).pop();
      final code = e.response?.statusCode;
      if (code == 429) {
        _showAiError(
            'Kunlik AI limitingiz tugadi. Ertaga qaytadan urinib ko\'ring.');
      } else if (code == 400) {
        _showAiError('Rasm yuborishda xatolik. Qayta urinib ko\'ring.');
      } else {
        _showAiError('Serverda xatolik yuz berdi. Qayta urinib ko\'ring.');
      }
    } catch (_) {
      if (cancelled || !mounted) return;
      Navigator.of(context).pop();
      _showAiError('Xatolik yuz berdi. Qayta urinib ko\'ring.');
    }
  }

  void _showAiError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.dmSans()),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Future.delayed(
                  const Duration(milliseconds: 300),
                  () => _firstViewBadgeAnim.forward(),
                ),
              );
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
          return _buildBody(context, (state as DetailLoaded).data, isDark);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FurnitureMaterialColorsResponse data,
    bool isDark,
  ) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final safeBtm = mq.padding.bottom;
    final fullH = _kImageH + safeTop + _overscroll;
    final colors = data.colors;
    final colorIdx = _colorIdx.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
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
                      onTryInRoom: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          Navigator.of(context).pushNamed(Pages.login);
                          return;
                        }
                        final idx = _colorIdx.clamp(
                            0, colors.isEmpty ? 0 : colors.length - 1);
                        _onTryInRoom(
                          colors.isNotEmpty
                              ? (colors[idx].firstComboImage ?? '')
                              : '',
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverPadding(padding: EdgeInsets.only(bottom: safeBtm + 40)),
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
            onFav: () => _requireAuth(context, () {
              HapticFeedback.lightImpact();
              setState(() => _isFav = !_isFav);
            }),
          ),
        ),
      ],
    );
  }
}
