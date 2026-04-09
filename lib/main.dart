import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/core/router/app_router.dart';
import 'package:evim_furniture/src/core/services/notification_service.dart';
import 'package:evim_furniture/src/core/theme/app_theme.dart';
import 'package:evim_furniture/src/core/theme/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await bugsnag.start(apiKey: '9eea7bfa5d04d84c34f5d1525a9d1189');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDi();

  // Initialize notification service
  await NotificationService.instance.init();

  // If user is logged in, register FCM token and listen for refreshes
  if (FirebaseAuth.instance.currentUser != null) {
    NotificationService.instance.registerToken();
    NotificationService.instance.listenTokenRefresh();
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('uz')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (_, __) => MaterialApp(
        title: 'Evim Furniture',
        theme: AppTheme.light,
        themeMode: themeController.mode,
        darkTheme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
      ),
    );
  }
}
