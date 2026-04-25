part of '../detail_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collapsedColor =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: collapsed
            ? Center(child: Icon(icon, size: 20, color: collapsedColor))
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
      ),
    );
  }
}

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
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.88)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collapsedColor =
        isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final iconColor = widget.isFav
        ? const Color(0xFFE53935)
        : (widget.collapsed ? collapsedColor : Colors.white);

    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Icon(
        widget.isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(widget.isFav),
        size: 21,
        color: iconColor,
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: widget.collapsed
            ? Center(child: ScaleTransition(scale: _scale, child: icon))
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isFav
                      ? const Color(0xFFE53935).withValues(alpha: 0.55)
                      : Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ScaleTransition(scale: _scale, child: icon),
                ),
              ),
      ),
    );
  }
}
