import 'dart:math' as math;
import 'dart:ui';

import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/login_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:evim_furniture/src/features/auth/domain/model/user_model.dart';
import 'package:evim_furniture/src/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:evim_furniture/src/features/choose_lang/choose_language_screen.dart';
import 'package:evim_furniture/src/features/detail/presentation/screens/detail_screen.dart';
import 'package:evim_furniture/src/features/intro/screens/intro_screen.dart';
import 'package:evim_furniture/src/features/shell/presentation/screens/shell_screen.dart';
import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Pages.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Pages.intro:
        return MaterialPageRoute(builder: (_) => const IntroductionScreen());
      case Pages.chooseLanguage:
        return MaterialPageRoute(builder: (_) => const ChooseLanguageScreen());

      case Pages.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Pages.otp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            type: args['type'] as String,
            destination: args['destination'] as String,
          ),
        );
      case Pages.completeProfile:
        final initialName = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(initialName: initialName),
        );
      case Pages.editProfile:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(user: user),
        );
      case Pages.notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationsScreen());
      case Pages.home:
        return MaterialPageRoute(builder: (_) => const ShellScreen());

      case Pages.furnitureDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 560),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (_, __, ___) => DetailScreen(
            furnitureId: args['furnitureId'] as String? ?? '',
            furnitureMaterialId:
                args['furnitureMaterialId'] as String? ?? '',
          ),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );
            return AnimatedBuilder(
              animation: curved,
              builder: (_, c) => ClipPath(
                clipper: _HiveRevealClipper(curved.value),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: anim,
                      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
                      reverseCurve:
                          const Interval(0.65, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: c,
                ),
              ),
              child: child,
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

// Circular reveal that expands from the center of the screen —
// the "hive cell opening" effect.
class _HiveRevealClipper extends CustomClipper<Path> {
  const _HiveRevealClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      center.dx * center.dx + center.dy * center.dy,
    );
    final radius = lerpDouble(0, maxRadius, fraction)!;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_HiveRevealClipper old) => old.fraction != fraction;
}
