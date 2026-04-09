import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/login_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:evim_furniture/src/features/choose_lang/choose_language_screen.dart';
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
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      case Pages.home:
        return MaterialPageRoute(builder: (_) => const ShellScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
