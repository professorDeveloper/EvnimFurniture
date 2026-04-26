import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../domain/usecases/try_in_room_usecase.dart';
import 'ai_result_screen.dart';

class AiTryRoomScreen extends StatefulWidget {
  const AiTryRoomScreen({super.key, required this.furnitureImageUrl});

  final String furnitureImageUrl;

  @override
  State<AiTryRoomScreen> createState() => _AiTryRoomScreenState();
}

class _AiTryRoomScreenState extends State<AiTryRoomScreen> {
  bool _loading = false;
  String? _error;
  double _progress = 0;
  Timer? _progressTimer;
  int _currentStep = 0;
  DateTime _startTime = DateTime.now();

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progress = 0;
    _currentStep = 0;
    _startTime = DateTime.now();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
        _progress = (elapsed / 60000.0).clamp(0.0, 0.95);
        if (_progress > 0.15 && _currentStep == 0) _currentStep = 1;
        if (_progress > 0.4 && _currentStep == 1) _currentStep = 2;
        if (_progress > 0.7 && _currentStep == 2) _currentStep = 3;
      });
    });
  }

  Future<void> _pickAndProcess(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (picked == null || !mounted) return;
    setState(() { _loading = true; _error = null; });
    _startProgress();
    try {
      final result = await sl<TryInRoomUseCase>()(
        roomImagePath: picked.path,
        furnitureImageUrl: widget.furnitureImageUrl,
      );
      _progressTimer?.cancel();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AiResultScreen(base64Image: result)),
      );
    } catch (e) {
      _progressTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _loading = false; _progress = 0; _currentStep = 0;
        _error = e.toString().contains('429')
            ? AppTexts.detailAiLimitExceeded.tr()
            : AppTexts.detailAiError.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFFAF9F7);
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub = isDark ? AppColors.grey400 : AppColors.grey500;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _loading
            ? _buildLoading(text, sub, isDark)
            : _buildPicker(text, sub, isDark, cardBg),
      ),
    );
  }

  Widget _buildPicker(Color text, Color sub, bool isDark, Color cardBg) {
    return Column(
      children: [
        _buildTopBar(text, isDark),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                // Furniture card
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: cardBg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.furnitureImageUrl,
                          memCacheWidth: 800,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Center(
                            child: Icon(Icons.chair_rounded, size: 56, color: sub)),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14, left: 16, right: 16,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text('AI', style: GoogleFonts.dmSans(
                                      fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(AppTexts.detailSelectRoomPhoto.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: text, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(AppTexts.detailSelectRoomPhotoDesc.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 14, color: sub, height: 1.5)),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!,
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Camera button
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: () => _pickAndProcess(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(AppTexts.authPickCamera.tr(),
                          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton(
                    onPressed: () => _pickAndProcess(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: (isDark ? Colors.white : AppColors.secondary).withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_rounded, size: 20,
                          color: isDark ? Colors.white : AppColors.secondary),
                        const SizedBox(width: 10),
                        Text(AppTexts.authPickGallery.tr(),
                          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.secondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(Color text, Color sub, bool isDark) {
    final steps = [
      'aiStepAnalyzing'.tr(),
      'aiStepSelecting'.tr(),
      'aiStepPlacing'.tr(),
      'aiStepFinishing'.tr(),
    ];

    return Column(
      children: [
        const Spacer(flex: 2),

        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 36),
        ),
        const SizedBox(height: 24),

        Text(AppTexts.detailAiProcessing.tr(),
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w800, color: text, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(AppTexts.detailAiProcessingDesc.tr(),
          style: GoogleFonts.dmSans(fontSize: 13, color: sub)),

        const SizedBox(height: 36),

        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(steps[_currentStep.clamp(0, 3)],
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                  Text('${(_progress * 100).toInt()}%',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: text)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Steps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              for (int i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _currentStep
                              ? AppColors.secondary
                              : i == _currentStep
                                  ? AppColors.secondary.withValues(alpha: 0.15)
                                  : Colors.transparent,
                          border: Border.all(
                            color: i <= _currentStep ? AppColors.secondary : AppColors.grey300,
                            width: i < _currentStep ? 0 : 1.5,
                          ),
                        ),
                        child: i < _currentStep
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : i == _currentStep
                                ? Center(
                                    child: Container(
                                      width: 6, height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Text(steps[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: i <= _currentStep ? FontWeight.w600 : FontWeight.w400,
                          color: i < _currentStep ? text : i == _currentStep ? AppColors.secondary : sub)),
                      if (i == _currentStep) ...[
                        const SizedBox(width: 8),
                        SizedBox(width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5,
                            color: AppColors.secondary.withValues(alpha: 0.4))),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),

        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildTopBar(Color text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 20, color: text),
            ),
          ),
          const Spacer(),
          Text(AppTexts.detailTryInRoom.tr(),
            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: text)),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
