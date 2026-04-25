import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../home/data/model/furniture_material_colors_response.dart';
import 'native_ar_screen.dart';

class ArViewerScreen extends StatefulWidget {
  const ArViewerScreen({
    super.key,
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
  State<ArViewerScreen> createState() => _ArViewerScreenState();
}

class _ArViewerScreenState extends State<ArViewerScreen> {
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

  void _openNativeAR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NativeArScreen(
          modelUrl: widget.modelUrl,
          title: widget.title,
        ),
      ),
    );
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
    final bgColor =
        isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F0);
    final onBg = isDark ? Colors.white : Colors.black87;
    final selectedColor = hasColors ? widget.colors[_colorIdx] : null;
    final colorJs = selectedColor != null ? _colorJs(selectedColor) : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: ModelViewer(
                  key: ValueKey(
                      '${widget.modelUrl}_${selectedColor?.hexCode ?? ''}'),
                  src: widget.modelUrl,
                  ar: false,
                  autoRotate: true,
                  cameraControls: true,
                  backgroundColor: bgColor,
                  relatedJs: colorJs,
                ),
              ),
            ),

            Positioned(
              top: safeTop + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(_colorIdx),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: onBg,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _CircleBtn(
                    icon: Icons.view_in_ar_rounded,
                    onTap: _openNativeAR,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            if (hasColors)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A).withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: safeBtm + 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: onBg.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppTexts.detailColor.tr(),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: onBg.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 68,
                        child: ListView.separated(
                          controller: _colorScroll,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.colors.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _ColorItem(
                            color: widget.colors[i],
                            isSelected: i == _colorIdx,
                            onBg: onBg,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _colorIdx = i);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _ColorItem extends StatelessWidget {
  const _ColorItem({
    required this.color,
    required this.isSelected,
    required this.onBg,
    required this.onTap,
  });

  final FurnitureMaterialColor color;
  final bool isSelected;
  final Color onBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 42 : 36,
              height: isSelected ? 42 : 36,
              padding: EdgeInsets.all(isSelected ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.color,
                  border: Border.all(
                    color: onBg.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              color.name,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: isSelected ? onBg : onBg.withValues(alpha: 0.4),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
