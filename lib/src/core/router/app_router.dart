import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/login_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:evim_furniture/src/features/auth/domain/model/user_model.dart';
import 'package:evim_furniture/src/features/notifications/presentation/screens/notifications_screen.dart';
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

      default:
        return MaterialPageRoute(
          builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
