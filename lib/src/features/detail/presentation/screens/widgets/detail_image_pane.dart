part of '../detail_screen.dart';

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
              if (showing3d) ...[
                _ViewToggleBtn(
                  icon: Icons.photo_library_rounded,
                  label: AppTexts.detailPhotos.tr(),
                  onTap: on360Toggle,
                ),
                const SizedBox(width: 8),
                _ViewToggleBtn(
                  icon: Icons.open_in_full_rounded,
                  label: AppTexts.detailExpand.tr(),
                  onTap: onFullscreen,
                ),
              ],
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                opacity: ((overscroll - 10) / 60).clamp(0.0, 1.0),
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
