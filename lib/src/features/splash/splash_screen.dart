import 'package:evim_furniture/src/core/constants/app_icons.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const _storage = FlutterSecureStorage();
  static const _onboardingKey = 'onboarding_done';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final onboardingDone = await _storage.read(key: _onboardingKey);

    if (!mounted) return;

    if (onboardingDone != 'true') {
      Navigator.pushReplacementNamed(context, Pages.chooseLanguage);
      return;
    }

    // Check if user is already signed in via Firebase
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // User is signed in — go to home
      Navigator.pushReplacementNamed(context, Pages.home);
    } else {
      // Not signed in — go to home (profile tab will show login prompt)
      Navigator.pushReplacementNamed(context, Pages.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Hero(
              tag: 'app_logo',
              child: SvgPicture.asset(
                AppIcons.appIcon,
                fit: BoxFit.contain,
                width: size.width * 0.65,
                height: size.width * 0.65,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
