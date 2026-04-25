import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';

class AiResultScreen extends StatefulWidget {
  const AiResultScreen({super.key, required this.base64Image});

  final String base64Image;

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  bool _saving = false;
  bool _sharing = false;
  Uint8List? _bytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    try {
      final str = widget.base64Image.contains(',')
          ? widget.base64Image.split(',').last
          : widget.base64Image;
      _bytes = base64Decode(str);
    } catch (_) {
      _hasError = true;
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await Gal.putImageBytes(_bytes!);
      _showSnack(AppTexts.detailSavedToGallery.tr());
    } catch (_) {
      _showSnack(AppTexts.detailSaveError.tr(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ai_result_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(_bytes!);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: AppTexts.detailAiResult.tr(),
      );
    } catch (_) {
      _showSnack(AppTexts.detailShareError.tr(), isError: true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeBtm = MediaQuery.of(context).padding.bottom;
    final pageBg = isDark ? AppColors.darkBackground : AppColors.background;
    final panelBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final hint = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.38)
        : AppColors.onSurfaceVariant.withValues(alpha: 0.65);

    if (_hasError || _bytes == null) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: pageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_rounded, size: 52, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(
                AppTexts.detailAiError.tr(),
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 18),
            const SizedBox(width: 6),
            Text(
              AppTexts.detailAiResult.tr(),
              style: GoogleFonts.dmSans(
                color: text,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    _bytes!,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, safeBtm + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        icon: Icons.download_rounded,
                        label: AppTexts.save.tr(),
                        loading: _saving,
                        onTap: _save,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionBtn(
                        icon: Icons.share_rounded,
                        label: AppTexts.detailShare.tr(),
                        loading: _sharing,
                        onTap: _share,
                        outlined: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pinch_rounded, color: hint, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      AppTexts.detailPinchToZoom.tr(),
                      style: GoogleFonts.dmSans(color: hint, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = outlined
        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant)
        : AppColors.secondary;
    final foreground = outlined ? AppColors.secondary : Colors.white;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
