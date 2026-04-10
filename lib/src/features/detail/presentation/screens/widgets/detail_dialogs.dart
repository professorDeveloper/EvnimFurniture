part of '../detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth required bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AuthRequiredSheet extends StatelessWidget {
  const _AuthRequiredSheet({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;

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
              color: _kGold.withValues(alpha: 0.12),
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
            style: GoogleFonts.dmSans(fontSize: 13, color: sub, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'login'.tr(),
                style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: sub, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image source picker sheet (Camera / Gallery)
// ─────────────────────────────────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
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
            style: GoogleFonts.dmSans(fontSize: 13, color: sub, height: 1.4),
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
              style: GoogleFonts.dmSans(fontSize: 14, color: sub),
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
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
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
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI loading dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AiLoadingDialog extends StatefulWidget {
  const _AiLoadingDialog();

  @override
  State<_AiLoadingDialog> createState() => _AiLoadingDialogState();
}

class _AiLoadingDialogState extends State<_AiLoadingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;
  int _dotCount = 0;
  late final Timer _dotTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount + 1) % 4);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _dotTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final dots = '.' * _dotCount;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: bg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: _kGold,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'AI tayyorlamoqda$dots',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '10–20 soniya kutib turing\nIltimos, sahifani yopmang',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: sub, height: 1.5),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => LinearProgressIndicator(
                    backgroundColor:
                        isDark ? AppColors.darkDivider : AppColors.grey100,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_kGold),
                    minHeight: 4,
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

// ─────────────────────────────────────────────────────────────────────────────
// AI result full-screen page
// ─────────────────────────────────────────────────────────────────────────────

class _AiResultPage extends StatelessWidget {
  const _AiResultPage({required this.base64Image, this.remaining});

  final String base64Image;
  final int? remaining;

  Uint8List _decode() {
    final str = base64Image.contains(',')
        ? base64Image.split(',').last
        : base64Image;
    return base64Decode(str);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
        centerTitle: true,
        title: Text(
          'AI Natija',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          if (remaining != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$remaining ta qoldi',
                    style: GoogleFonts.dmSans(
                      color: _kGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.fromLTRB(
                24, 10, 24, MediaQuery.of(context).padding.bottom + 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pinch_rounded,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Kattalashtirish uchun ikki barmoq bilan tortib ko\'ring',
                  style:
                      GoogleFonts.dmSans(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
