import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:evim_furniture/src/features/home/presentation/screens/home_screen.dart';
import 'package:evim_furniture/src/features/materials/presentation/screens/materials_screen.dart';
import 'package:evim_furniture/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../detail/presentation/screens/ai_try_room_screen.dart';
import '../../../favourites/presentation/bloc/favourites_bloc.dart';
import '../../../home/domain/usecases/get_home_data_usecase.dart';
import '../../../materials/presentation/bloc/materials_bloc.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final FavouritesBloc _favouritesBloc;
  late AnimationController _fabController;
  late Animation<double> _fabScale;
  late Animation<double> _fabGlow;

  static const List<_NavItemData> _itemsData = <_NavItemData>[
    _NavItemData(
      labelKey: AppTexts.navHome,
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
    ),
    _NavItemData(
      labelKey: AppTexts.materialsTitle,
      icon: CupertinoIcons.cube_box,
      activeIcon: CupertinoIcons.cube_box_fill,
    ),
    _NavItemData(
      labelKey: AppTexts.navFavorites,
      icon: CupertinoIcons.heart,
      activeIcon: CupertinoIcons.heart_fill,
    ),
    _NavItemData(
      labelKey: AppTexts.navProfile,
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
  ];

  late final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    BlocProvider(
      create: (_) => sl<MaterialsBloc>(),
      child: const MaterialsScreen(),
    ),
    const FavouritesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _favouritesBloc = sl<FavouritesBloc>()..add(FavouritesLoadRequested());
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fabScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    _fabGlow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  void _showAiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiPickerSheet(
        onSelect: (imageUrl) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AiTryRoomScreen(furnitureImageUrl: imageUrl),
            ),
          );
        },
      ),
    );
  }

  void _onTabTap(int i) {
    setState(() => _currentIndex = i);
    if (i == 2) {
      _favouritesBloc.add(FavouritesLoadRequested());
    }
  }

  @override
  void dispose() {
    _favouritesBloc.close();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        floatingActionButton: _AiFab(
          scaleAnimation: _fabScale,
          glowAnimation: _fabGlow,
          onPressed: () => _showAiPicker(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: BlocProvider.value(
          value: _favouritesBloc,
          child: Container(
            color: isDark ? AppColors.darkBackground : AppColors.white,
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          elevation: 0,
          padding: EdgeInsets.zero,
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          child: _BottomNavBar(
            itemsData: _itemsData,
            currentIndex: _currentIndex,
            onTap: _onTabTap,
          ),
        ),
      ),
    );
  }
}

class _AiFab extends StatelessWidget {
  const _AiFab({
    required this.scaleAnimation,
    required this.glowAnimation,
    required this.onPressed,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (_, child) => Transform.scale(
        scale: scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: glowAnimation,
            builder: (_, child) => Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: glowAnimation.value * 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: child,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.itemsData,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItemData> itemsData;
  final int currentIndex;
  final ValueChanged<int> onTap;

  Widget _navItem(_NavItemData item, int index, Color active, Color inactive) {
    final bool isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey<bool>(isActive),
                size: 24,
                color: isActive ? active : inactive,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? active : inactive,
              ),
              child: Text(item.labelKey.tr()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark ? AppColors.primary300 : AppColors.secondary;
    final Color inactiveColor = isDark ? AppColors.grey600 : AppColors.grey400;

    return Row(
      children: <Widget>[
        _navItem(itemsData[0], 0, activeColor, inactiveColor),
        _navItem(itemsData[1], 1, activeColor, inactiveColor),
        const SizedBox(width: 72),
        _navItem(itemsData[2], 2, activeColor, inactiveColor),
        _navItem(itemsData[3], 3, activeColor, inactiveColor),
      ],
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
}

class _AiPickerSheet extends StatefulWidget {
  const _AiPickerSheet({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  State<_AiPickerSheet> createState() => _AiPickerSheetState();
}

class _AiPickerSheetState extends State<_AiPickerSheet> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<GetHomeDataUseCase>().call().then((d) => d.topCombinations);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textMain = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final sub = isDark ? AppColors.grey500 : AppColors.grey600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppTexts.detailTryInRoom.tr(),
                        style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: textMain)),
                      const SizedBox(height: 2),
                      Text('aiPickFurniture'.tr(),
                        style: GoogleFonts.dmSans(fontSize: 13, color: sub)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.5)),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: sub),
                        const SizedBox(height: 12),
                        Text(AppTexts.materialSheetEmpty.tr(),
                          style: GoogleFonts.dmSans(fontSize: 14, color: sub)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                  itemCount: items.length,
                  cacheExtent: 300,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final name = item.furniture.name as String;
                    final material = item.material.name as String;
                    final image = item.displayImage as String?;
                    return GestureDetector(
                      onTap: () {
                        if (image != null && image.isNotEmpty) widget.onSelect(image);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.grey200, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: image != null && image.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: image, memCacheWidth: 400, fit: BoxFit.cover, width: double.infinity,
                                      placeholder: (_, __) => ColoredBox(color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100),
                                      errorWidget: (_, __, ___) => Center(child: Icon(Icons.chair_outlined, size: 32, color: sub)))
                                  : Center(child: Icon(Icons.chair_outlined, size: 32, color: sub)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: textMain)),
                                  const SizedBox(height: 2),
                                  Text(material, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(fontSize: 11, color: sub)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
