import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class NativeArScreen extends StatefulWidget {
  const NativeArScreen({
    super.key,
    required this.modelUrl,
    required this.title,
  });

  final String modelUrl;
  final String title;

  @override
  State<NativeArScreen> createState() => _NativeArScreenState();
}

class _NativeArScreenState extends State<NativeArScreen> {
  static const _arChannel = MethodChannel('com.evim/ar');
  static bool _arOpening = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openIOSAR());
    }
  }

  Future<void> _openIOSAR() async {
    if (_arOpening) return;
    _arOpening = true;
    try {
      await _arChannel.invokeMethod('openAR', {
        'glbUrl': widget.modelUrl,
        'title': widget.title,
        'locale': context.locale.languageCode,
      });
    } catch (e) {
      debugPrint('iOS AR error: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _arOpening = false;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : Colors.black87;
    final safeTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                src: widget.modelUrl,
                ar: true,
                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                arScale: ArScale.auto,
                autoRotate: true,
                cameraControls: true,
                shadowIntensity: 1,
                backgroundColor: bgColor,
                interactionPrompt: InteractionPrompt.none,
              ),
            ),
            Positioned(
              top: safeTop + 8,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
