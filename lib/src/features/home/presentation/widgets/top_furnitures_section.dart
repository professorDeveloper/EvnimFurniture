import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../domain/model/furniture_item.dart';
import '../../domain/model/material_item.dart';
import 'section_header.dart';

class TopFurnituresSection extends StatelessWidget {
  const TopFurnituresSection({
    super.key,
    required this.items,
    required this.materials,
  });

  final List<FurnitureItem> items;
  final List<MaterialItem> materials;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double w = MediaQuery.of(context).size.width;

    final double cardW = (w * 0.36).clamp(120.0, 160.0);
    final double imgH = cardW * 0.86;

    const double infoH = 80.0;
    final double listH = imgH + infoH + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppTexts.topFurnitures.tr(), isDark: isDark),
        const SizedBox(height: 12),
        SizedBox(
          height: listH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
              child: _FurnitureCard(
                item: items[i],
                isDark: isDark,
                cardW: cardW,
                imgH: imgH,
                onTap: () => {}
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FurnitureCard extends StatefulWidget {
  const _FurnitureCard({
    required this.item,
    required this.isDark,
    required this.cardW,
    required this.imgH,
    required this.onTap,
  });

  final FurnitureItem item;
  final bool isDark;
  final double cardW;
  final double imgH;
  final VoidCallback onTap;

  @override
  State<_FurnitureCard> createState() => _FurnitureCardState();
}

class _FurnitureCardState extends State<_FurnitureCard>
    with TickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  late bool _fav;
  bool _pulsing = false;

  @override
  void initState() {
    super.initState();
    _fav = widget.item.isFavorited;

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.32).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _pulseCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulseCtrl.reverse();
    });

    _startHeartbeat();
  }

  Future<void> _startHeartbeat() async {
    _pulsing = true;
    while (_pulsing && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_pulsing || !mounted) break;
      _pulseCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_pulsing || !mounted) break;
      _pulseCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulsing = false;
    _pressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() => _pressCtrl.reverse();

  void _toggleFav() {
    HapticFeedback.lightImpact();
    _pulseCtrl.forward(from: 0);
    setState(() => _fav = !_fav);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final item = widget.item;
    final cw = widget.cardW;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final imgBg =
    isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2F2F2);
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.45)
        : AppColors.grey500;
    final borderC = isDark ? AppColors.darkDivider : AppColors.grey200;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (_, child) => Opacity(opacity: _pressAnim.value, child: child),
        child: Container(
          width: cw,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderC, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: isDark ? 0.24 : 0.06),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cw,
                  height: widget.imgH,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: imgBg),
                      _buildImage(),
                      if (item.stats.avgRating > 0)
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
                                  item.stats.avgRating.toStringAsFixed(1),
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
                      if (item.tags.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.tags.first,
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _toggleFav,
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _fav
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.90),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ScaleTransition(
                                scale: _pulseAnim,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Icon(
                                    _fav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(_fav),
                                    size: 15,
                                    color: _fav
                                        ? AppColors.primary
                                        : AppColors.grey400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
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
                      const SizedBox(height: 6),

                      // Stats qatori
                      _StatsRow(stats: item.stats, subColor: textSub),

                      if (item.colors.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        _ColorSwatches(colors: item.colors),
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
  }

  Widget _buildImage() {
    final String? url = widget.item.thumbnailImage;
    final Color bg =
    widget.isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF2F2F2);
    if (url == null || url.isEmpty) {
      return Center(
        child: Icon(Icons.chair_outlined,
            size: widget.cardW * 0.30, color: AppColors.grey300),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => ColoredBox(color: bg),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.chair_outlined,
            size: widget.cardW * 0.30, color: AppColors.grey300),
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final _scroll = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  @override
  void dispose() {
    _running = false;
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _maybeStart() async {
    if (!mounted || !_scroll.hasClients) return;
    if (_scroll.position.maxScrollExtent <= 0) return;
    _running = true;
    while (_running && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_running || !mounted || !_scroll.hasClients) break;
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) break;
      final ms = (max / 40 * 1000).round().clamp(600, 6000);
      await _scroll.animateTo(
        max,
        duration: Duration(milliseconds: ms),
        curve: Curves.linear,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_running || !mounted || !_scroll.hasClients) break;
      _scroll.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style, maxLines: 1),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.subColor});

  final FurnitureStats stats;
  final Color subColor;

  static const double _sz = 10.0;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.0,
      color: subColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _item(Icons.visibility_outlined, '${stats.viewCount}', style),
        if (stats.materialCount > 0) ...[
          _dot(),
          _item(Icons.palette_outlined, '${stats.materialCount}', style),
        ],
      ],
    );
  }

  Widget _item(IconData icon, String label, TextStyle style) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: _sz, color: subColor),
      const SizedBox(width: 2),
      Text(label, style: style),
    ],
  );

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Container(
      width: 2.5,
      height: 2.5,
      decoration: BoxDecoration(shape: BoxShape.circle, color: subColor),
    ),
  );
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches({required this.colors});

  final List<MaterialDefaultColor> colors;

  static const double _sz = 10.0;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    final visible = colors.take(3).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final extra = colors.length - visible.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          visible.length,
              (i) => Padding(
            padding:
            EdgeInsets.only(right: i < visible.length - 1 ? _sz * 0.4 : 0),
            child: Container(
              width: _sz,
              height: _sz,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: visible[i].color,
                border: Border.all(color: AppColors.grey300, width: 0.8),
              ),
            ),
          ),
        ),
        if (extra > 0) ...[
          const SizedBox(width: 2),
          Text('+$extra',
              style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey400)),
        ],
      ],
    );
  }
}