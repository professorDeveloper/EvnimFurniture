import 'package:evim_furniture/src/core/router/pages.dart';
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
