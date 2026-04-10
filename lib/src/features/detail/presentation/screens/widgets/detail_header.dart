part of '../detail_screen.dart';

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
    final collapsedBg = isDark ? AppColors.darkSurface : Colors.white;
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

// ─────────────────────────────────────────────────────────────────────────────
// Header icon button
// ─────────────────────────────────────────────────────────────────────────────

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
// Animated like button
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
