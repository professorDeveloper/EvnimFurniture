part of '../detail_screen.dart';

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey400,
        ),
      );
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.grey200,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkOnSurface : AppColors.grey600,
        ),
      ),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: isDark ? AppColors.darkDivider : AppColors.grey100,
        height: 1,
      ),
    );
  }
}

class _SectionHdr extends StatelessWidget {
  const _SectionHdr({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: AppColors.grey500,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubLabel(text: label),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
      child: Center(
        child: Icon(
          Icons.chair_outlined,
          size: 64,
          color: isDark ? AppColors.grey700 : AppColors.grey300,
        ),
      ),
    );
  }
}

class _MatPh extends StatelessWidget {
  const _MatPh();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
      child: Center(
        child: Icon(
          Icons.texture_rounded,
          size: 22,
          color: isDark ? AppColors.grey700 : AppColors.grey300,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? AppColors.darkBackground : AppColors.grey100,
          ),
        ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        ),
        Positioned(
          top: top + 8,
          left: 12,
          child: _HBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            collapsed: false,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onBack, this.onRetry});

  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 52,
                  color: isDark ? AppColors.grey600 : AppColors.grey300,
                ),
                const SizedBox(height: 16),
                Text(
                  AppTexts.errorNoConnection.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.errorNoConnectionDesc.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 24),
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      AppTexts.errorRetry.tr(),
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: top + 8,
          left: 12,
          child: _HBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            collapsed: false,
          ),
        ),
      ],
    );
  }
}
