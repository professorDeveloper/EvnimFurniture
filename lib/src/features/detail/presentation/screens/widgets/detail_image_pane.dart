part of '../detail_screen.dart';

class _ImagePane extends StatefulWidget {
  const _ImagePane({
    required this.items,
    required this.pageCtrl,
    required this.page,
    required this.showing3d,
    required this.has3dModel,
    required this.modelFile,
    required this.onPageChanged,
    this.colorHex,
    this.on360,
    this.onAr,
    this.onExpand,
    this.onImageTap,
  });

  final List<String> items;
  final PageController pageCtrl;
  final int page;
  final bool showing3d;
  final bool has3dModel;
  final String? modelFile;
  final String? colorHex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? on360;
  final VoidCallback? onAr;
  final VoidCallback? onExpand;
  final ValueChanged<int>? onImageTap;

  @override
  State<_ImagePane> createState() => _ImagePaneState();
}

class _ImagePaneState extends State<_ImagePane> {
  bool _modelMounted = false;

  @override
  void didUpdateWidget(_ImagePane old) {
    super.didUpdateWidget(old);
    if (widget.showing3d && !_modelMounted && widget.has3dModel) {
      setState(() => _modelMounted = true);
    }
    if (old.modelFile != widget.modelFile) {
      setState(() => _modelMounted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Offstage(
          offstage: widget.showing3d,
          child: RepaintBoundary(
            child: PageView.builder(
              controller: widget.pageCtrl,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.items.isEmpty ? 1 : widget.items.length,
              onPageChanged: widget.onPageChanged,
              itemBuilder: (_, i) => widget.items.isEmpty
                  ? const _ImgPlaceholder()
                  : GestureDetector(
                      onTap: () => widget.onImageTap?.call(i),
                      child: _PageImage(url: widget.items[i]),
                    ),
            ),
          ),
        ),
        if (widget.has3dModel && _modelMounted)
          Offstage(
            offstage: !widget.showing3d,
            child: RepaintBoundary(
              child: _InlineModelViewer(
                key: ValueKey('${widget.modelFile}_${widget.colorHex ?? ''}'),
                modelUrl: widget.modelFile!,
                backgroundColor: bgColor,
                colorHex: widget.colorHex,
              ),
            ),
          ),
        if (!widget.showing3d)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        if (!widget.showing3d && widget.items.length > 1)
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: _PageDots(current: widget.page, count: widget.items.length),
          ),
        if (widget.has3dModel)
          Positioned(
            bottom: 44,
            right: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showing3d) ...[
                  _ViewBtn(
                    icon: Icons.photo_library_outlined,
                    label: AppTexts.detailPhotos.tr(),
                    onTap: widget.on360 ?? () {},
                  ),
                  const SizedBox(width: 8),
                  _ViewBtn(
                    icon: Icons.open_in_full_rounded,
                    label: AppTexts.detailExpand.tr(),
                    onTap: widget.onExpand ?? () {},
                  ),
                ] else ...[
                  _ViewBtn(
                    icon: Icons.view_in_ar_rounded,
                    label: 'AR',
                    onTap: widget.onAr ?? () {},
                  ),
                  const SizedBox(width: 8),
                  _ViewBtn(
                    icon: Icons.rotate_90_degrees_ccw_rounded,
                    label: '360°',
                    onTap: widget.on360 ?? () {},
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
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineModelViewer extends StatefulWidget {
  const _InlineModelViewer({
    super.key,
    required this.modelUrl,
    required this.backgroundColor,
    this.colorHex,
  });

  final String modelUrl;
  final Color backgroundColor;
  final String? colorHex;

  @override
  State<_InlineModelViewer> createState() => _InlineModelViewerState();
}

class _InlineModelViewerState extends State<_InlineModelViewer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String? _buildColorJs() {
    final hex = widget.colorHex;
    if (hex == null || hex.isEmpty) return null;
    final cleanHex = '#${hex.replaceFirst('#', '')}';
    return '''
const mv = document.querySelector('model-viewer');
mv.addEventListener('load', () => {
  try {
    const [mat] = mv.model.materials;
    mat.pbrMetallicRoughness.setBaseColorFactor('$cleanHex');
  } catch(e) {}
});
''';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ModelViewer(
      src: widget.modelUrl,
      ar: false,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: widget.backgroundColor,
      relatedJs: _buildColorJs(),
    );
  }
}

class _ViewBtn extends StatelessWidget {
  const _ViewBtn({
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
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageImage extends StatelessWidget {
  const _PageImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImgPlaceholder();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 800,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
      ),
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
    final visible = count.clamp(0, 12);
    if (visible <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: active ? 18 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
