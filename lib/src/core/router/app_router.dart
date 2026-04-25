import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/login_screen.dart';
import 'package:evim_furniture/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:evim_furniture/src/features/auth/domain/model/user_model.dart';
import 'package:evim_furniture/src/features/help/presentation/screens/help_screen.dart';
import 'package:evim_furniture/src/features/legal/presentation/screens/legal_info_screen.dart';
import 'package:evim_furniture/src/features/legal/presentation/screens/privacy_policy_screen.dart';
import 'package:evim_furniture/src/features/legal/presentation/screens/service_terms_screen.dart';
import 'package:evim_furniture/src/features/view_all/presentation/screens/view_all_screen.dart';
import 'package:evim_furniture/src/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:evim_furniture/src/features/choose_lang/choose_language_screen.dart';
import 'package:evim_furniture/src/features/detail/presentation/screens/detail_screen.dart';
import 'package:evim_furniture/src/features/intro/screens/intro_screen.dart';
import 'package:evim_furniture/src/features/shell/presentation/screens/shell_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../features/category/domain/model/category_model.dart';
import '../../features/category/presentation/screens/categories_view_all_screen.dart';
import '../../features/category/presentation/screens/category_furniture_screen.dart';
import '../constants/app_texts.dart';
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
      case Pages.help:
        return MaterialPageRoute(
            builder: (_) => const HelpScreen());
      case Pages.legalInfo:
        return MaterialPageRoute(
            builder: (_) => const LegalInfoScreen());
      case Pages.privacyPolicy:
        return MaterialPageRoute(
            builder: (_) => const PrivacyPolicyScreen());
      case Pages.serviceTerms:
        return MaterialPageRoute(
            builder: (_) => const ServiceTermsScreen());
      case Pages.categoriesViewAll:
        return MaterialPageRoute(
          builder: (_) => const CategoriesViewAllScreen(),
        );
      case Pages.categoryFurniture:
        final category = settings.arguments as CategoryItem;
        return MaterialPageRoute(
          builder: (_) => CategoryFurnitureScreen(category: category),
        );
      case Pages.viewAll:
        final type = settings.arguments as ViewAllType;
        return MaterialPageRoute(
            builder: (_) => ViewAllScreen(type: type));
      case Pages.home:
        return MaterialPageRoute(builder: (_) => const ShellScreen());

      case Pages.furnitureDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DetailScreen(
            furnitureId: args['furnitureId'] as String? ?? '',
            furnitureMaterialId:
                args['furnitureMaterialId'] as String? ?? '',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
          Scaffold(body: Center(child: Text(AppTexts.routeNotFound.tr()))),
        );
    }
  }
}

