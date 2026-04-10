part of '../detail_screen.dart';

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub =
    isDark ? AppColors.darkOnSurface.withOpacity(0.55) : AppColors.grey500;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _kGold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: _kGold,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'loginRequired'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'loginRequiredDesc'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: sub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'login'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: sub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub =
    isDark ? AppColors.darkOnSurface.withOpacity(0.55) : AppColors.grey500;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Xona rasmini tanlang',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mebelni joylashtirishni xohlagan xonangiz rasmini yuklang',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: sub,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SourceTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceTile(
                  icon: Icons.photo_library_rounded,
                  label: 'Galereya',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: sub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _kGold, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiLoadingDialog extends StatefulWidget {
  const _AiLoadingDialog({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_AiLoadingDialog> createState() => _AiLoadingDialogState();
}

class _AiLoadingDialogState extends State<_AiLoadingDialog>
    with SingleTickerProviderStateMixin {
  static const _maxSeconds = 50;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final Timer _ticker;

  int _ticks = 0;
  bool _timedOut = false;

  int get _elapsed => _ticks ~/ 2;
  int get _dotCount => _ticks % 4;
  double get _progress => (_elapsed / _maxSeconds).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _ticks++);
      if (_elapsed >= _maxSeconds && !_timedOut) {
        setState(() => _timedOut = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) widget.onCancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub =
    isDark ? AppColors.darkOnSurface.withOpacity(0.55) : AppColors.grey500;
    final dots = '.' * _dotCount;
    final remaining = _maxSeconds - _elapsed;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _timedOut ? const AlwaysStoppedAnimation(1.0) : _pulse,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _timedOut
                        ? (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.grey200)
                        : _kGold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _timedOut
                        ? Icons.access_time_rounded
                        : Icons.auto_awesome_rounded,
                    color: _timedOut ? AppColors.grey500 : _kGold,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _timedOut ? 'Vaqt tugadi' : 'AI tayyorlamoqda$dots',
                  key: ValueKey(_timedOut),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _timedOut
                      ? 'Keyinroq urinib ko\'ring'
                      : 'Iltimos, sahifani yopmang',
                  key: ValueKey(_timedOut),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: sub,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor:
                        isDark ? AppColors.darkDivider : AppColors.grey100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _timedOut ? AppColors.grey400 : _kGold,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  if (!_timedOut) ...[
                    const SizedBox(width: 10),
                    Text(
                      '$remaining s',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sub,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: widget.onCancel,
                child: Text(
                  'Bekor qilish',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: sub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiResultPage extends StatefulWidget {
  const _AiResultPage({required this.base64Image});

  final String base64Image;

  @override
  State<_AiResultPage> createState() => _AiResultPageState();
}

class _AiResultPageState extends State<_AiResultPage> {
  bool _saving = false;
  bool _sharing = false;
  late final Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _decode(widget.base64Image);
  }

  Uint8List _decode(String source) {
    final str = source.contains(',') ? source.split(',').last : source;
    return base64Decode(str);
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(color: AppColors.onPrimary),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _save(Uint8List bytes) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await Gal.putImageBytes(
        bytes,
      );
      _showSnack('Galereyaga saqlandi');
    } catch (_) {
      _showSnack('Saqlashda xatolik yuz berdi', isError: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _share(Uint8List bytes) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final file =
      File('${dir.path}/ai_result_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'AI Natija',
      );
    } catch (_) {
      _showSnack('Ulashishda xatolik yuz berdi', isError: true);
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
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
        ? AppColors.darkOnSurface.withOpacity(0.38)
        : AppColors.onSurfaceVariant.withOpacity(0.65);
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: text,
            size: 18,
          ),
        ),
        centerTitle: true,
        title: Text(
          'AI Natija',
          style: GoogleFonts.dmSans(
            color: text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ColoredBox(
              color: pageBg,
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    _bytes,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: panelBg,
              border: Border(
                top: BorderSide(color: borderColor),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, safeBtm + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AiActionBtn(
                        icon: Icons.download_rounded,
                        label: 'Saqlash',
                        loading: _saving,
                        onTap: () => _save(_bytes),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AiActionBtn(
                        icon: Icons.share_rounded,
                        label: 'Ulashish',
                        loading: _sharing,
                        onTap: () => _share(_bytes),
                        outlined: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pinch_rounded,
                      color: hint,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Kattalashtirish uchun ikki barmoq bilan tortib ko\'ring',
                      style: GoogleFonts.dmSans(
                        color: hint,
                        fontSize: 11,
                      ),
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

class _AiActionBtn extends StatelessWidget {
  const _AiActionBtn({
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
        : _kGold;
    final foreground = outlined ? _kGold : AppColors.onPrimary;

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: _kGold.withOpacity(0.7), width: 1.5)
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
              Icon(
                icon,
                size: 18,
                color: foreground,
              ),
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