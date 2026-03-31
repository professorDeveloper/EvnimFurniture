import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_colors.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/features/favourites/presentation/screens/favourites_screen.dart';
import 'package:evim_furniture/src/features/home/presentation/screens/home_screen.dart';
import 'package:evim_furniture/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:evim_furniture/src/features/search/presentation/screens/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
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
      labelKey: AppTexts.navSearch,
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
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

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
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
          onPressed: () {},
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          color: isDark ? AppColors.darkBackground : AppColors.white,
          child: IndexedStack(index: _currentIndex, children: _pages),
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
            onTap: (int i) => setState(() => _currentIndex = i),
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 26,
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
    final Color activeColor = AppColors.secondary;
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
