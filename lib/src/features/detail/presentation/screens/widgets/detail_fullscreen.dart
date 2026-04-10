part of '../detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Keep-alive 3D model viewer
// ─────────────────────────────────────────────────────────────────────────────

class _KeepAliveModelViewer extends StatefulWidget {
  const _KeepAliveModelViewer({super.key, required this.modelUrl});

  final String modelUrl;

  @override
  State<_KeepAliveModelViewer> createState() => _KeepAliveModelViewerState();
}

class _KeepAliveModelViewerState extends State<_KeepAliveModelViewer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F0);
    return ModelViewer(
      src: widget.modelUrl,
      ar: false,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: bgColor,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fullscreen 3D viewer
// ─────────────────────────────────────────────────────────────────────────────

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

  String? _colorJs(FurnitureMaterialColor c) {
    if (c.isDefault || c.hexCode.isEmpty) return null;
    final hex = '#${c.hexCode.replaceFirst('#', '')}';
    return '''
const mv = document.querySelector('model-viewer');
mv.addEventListener('load', () => {
  try {
    const [mat] = mv.model.materials;
    mat.pbrMetallicRoughness.setBaseColorFactor('$hex');
  } catch(e) {}
});
''';
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBtm = MediaQuery.of(context).padding.bottom;
    final hasColors = widget.colors.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F0);
    final onBg = isDark ? Colors.white : Colors.black87;

    final selectedColor = hasColors ? widget.colors[_colorIdx] : null;
    final colorJs = selectedColor != null ? _colorJs(selectedColor) : null;

    return PopScope(
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                key: ValueKey('${widget.modelUrl}_${selectedColor?.hexCode ?? ''}'),
                src: widget.modelUrl,
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: bgColor,
                relatedJs: colorJs,
              ),
            ),
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
                      bgColor.withValues(alpha: 0.7),
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
                              color: onBg.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: onBg.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: onBg,
                              size: 20,
                            ),
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
                          color: onBg,
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
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.42)
                            : Colors.white.withValues(alpha: 0.55),
                        border: Border(
                          top: BorderSide(
                            color: onBg.withValues(alpha: 0.1),
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
                              color: onBg.withValues(alpha: 0.5),
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
                                        padding:
                                            EdgeInsets.all(sel ? 3 : 0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: sel
                                                ? _kGold
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: c.color,
                                            border: Border.all(
                                              color: onBg.withValues(
                                                  alpha: 0.15),
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
                                              ? onBg
                                              : onBg.withValues(alpha: 0.45),
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
