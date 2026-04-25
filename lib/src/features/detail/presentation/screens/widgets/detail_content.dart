part of '../detail_screen.dart';

class _MatOpt {
  const _MatOpt({required this.id, required this.name, this.image});

  final String id;
  final String name;
  final String? image;
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.data,
    required this.currentMaterialId,
    required this.colors,
    required this.colorIdx,
    required this.myRating,
    required this.isDark,
    required this.onMaterialChanged,
    required this.onColorChanged,
    required this.onRate,
    required this.onTryInRoom,
    required this.onImageTap,
  });

  final FurnitureMaterialColorsResponse data;
  final String currentMaterialId;
  final List<FurnitureMaterialColor> colors;
  final int colorIdx;
  final int? myRating;
  final bool isDark;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onRate;
  final VoidCallback onTryInRoom;
  final ValueChanged<int> onImageTap;

  @override
  Widget build(BuildContext context) {
    final furniture = data.furniture;
    final material = data.material;
    final hasMatInfo = !material.isEmpty;
    final selectedColor = colors.isNotEmpty ? colors[colorIdx] : null;

    final allMaterials = <_MatOpt>[
      if (hasMatInfo)
        _MatOpt(
          id: currentMaterialId,
          name: material.name,
          image: material.firstImage,
        ),
      ...data.otherMaterials
          .where((m) => m.furnitureMaterialId != currentMaterialId)
          .map((m) => _MatOpt(
                id: m.furnitureMaterialId,
                name: m.materialName,
                image: m.previewImage,
              )),
    ];

    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final textSub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        furniture.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasMatInfo) ...[
                  const SizedBox(height: 3),
                  Text(
                    material.name,
                    style: GoogleFonts.dmSans(fontSize: 13, color: textSub),
                  ),
                ],
                if (furniture.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: furniture.tags
                        .take(4)
                        .map((t) => _TagChip(label: t))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                _StatsRow(
                  stats: furniture.stats,
                  myRating: myRating,
                  onRate: onRate,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onTryInRoom,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                    label: Text(
                      AppTexts.detailTryInRoom.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (allMaterials.isNotEmpty) ...[
            const _Div(),
            _SectionHdr(label: AppTexts.detailMaterial.tr()),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: allMaterials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final opt = allMaterials[i];
                  return _MatCard(
                    opt: opt,
                    isSelected: opt.id == currentMaterialId,
                    onTap: () => onMaterialChanged(opt.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (colors.isNotEmpty) ...[
            const _Div(),
            _SectionHdr(label: AppTexts.detailColor.tr()),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                itemCount: colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _ColorSwatch(
                  color: colors[i],
                  isSelected: i == colorIdx,
                  onTap: () => onColorChanged(i),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (furniture.images.isNotEmpty) ...[
            const _Div(),
            _SectionHdr(label: AppTexts.detailImages.tr()),
            RepaintBoundary(
              child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  itemCount: furniture.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => onImageTap(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: furniture.images[i],
                          memCacheWidth: 200,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => ColoredBox(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.grey100,
                          ),
                          errorWidget: (_, __, ___) =>
                              const _ImgPlaceholder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (hasMatInfo || selectedColor != null) ...[
            const _Div(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasMatInfo)
                    _InfoPair(
                      label: AppTexts.detailMaterial.tr(),
                      value: material.name,
                    ),
                  if (selectedColor != null) ...[
                    if (hasMatInfo) const SizedBox(height: 12),
                    _InfoPair(
                      label: AppTexts.detailColor.tr(),
                      value: selectedColor.name,
                    ),
                  ],
                  if (hasMatInfo &&
                      (material.description?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 12),
                    _SubLabel(text: AppTexts.detailCareInstructions.tr()),
                    const SizedBox(height: 5),
                    Text(
                      material.description!,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: textMain,
                        height: 1.65,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (furniture.description?.isNotEmpty ?? false) ...[
            const _Div(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubLabel(text: AppTexts.detailAboutThisPiece.tr()),
                  const SizedBox(height: 5),
                  Text(
                    furniture.description!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: textMain,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.stats,
    required this.myRating,
    required this.onRate,
  });

  final FMCStats stats;
  final int? myRating;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.grey500;

    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = myRating != null
              ? i < myRating!
              : i < stats.avgRating.round();
          return GestureDetector(
            onTap: () => onRate(i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: filled ? _kGold : AppColors.grey300,
                size: 20,
              ),
            ),
          );
        }),
        const SizedBox(width: 6),
        Text(
          '${stats.ratingCount} ${AppTexts.detailReviews.tr()}',
          style: GoogleFonts.dmSans(fontSize: 12, color: sub),
        ),
        if (stats.viewCount > 0) ...[
          const SizedBox(width: 5),
          _Dot(),
          const SizedBox(width: 5),
          Text(
            '${stats.viewCount} ${AppTexts.detailViews.tr()}',
            style: GoogleFonts.dmSans(fontSize: 12, color: sub),
          ),
        ],
      ],
    );
  }
}

class _MatCard extends StatelessWidget {
  const _MatCard({
    required this.opt,
    required this.isSelected,
    required this.onTap,
  });

  final _MatOpt opt;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBorder =
        isDark ? _kGold.withValues(alpha: 0.8) : _kDark.withValues(alpha: 0.65);
    final unselectedBorder =
        isDark ? AppColors.darkDivider : AppColors.grey200;
    final labelColor = isSelected
        ? (isDark ? AppColors.darkOnSurface : _kDark)
        : (isDark ? AppColors.grey400 : AppColors.grey600);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 84,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected ? selectedBorder : unselectedBorder,
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _kDark.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.5),
                child: opt.image?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: opt.image!,
                        memCacheWidth: 200,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ColoredBox(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.grey100,
                        ),
                        errorWidget: (_, __, ___) => const _MatPh(),
                      )
                    : const _MatPh(),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              opt.name,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: labelColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final FurnitureMaterialColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark ? _kGold : _kDark;
    final labelColor = isSelected
        ? (isDark ? AppColors.darkOnSurface : _kDark)
        : AppColors.grey500;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              padding: EdgeInsets.all(isSelected ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ringColor : Colors.transparent,
                  width: isSelected ? 1.8 : 0,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.color,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.07),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              color.name,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: labelColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
