import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/di/injection.dart';
import 'package:evim_furniture/src/core/router/app_router.dart';
import 'package:evim_furniture/src/core/services/notification_service.dart';
import 'package:evim_furniture/src/core/theme/app_theme.dart';
import 'package:evim_furniture/src/core/theme/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDi();

  await NotificationService.instance.init();

  if (FirebaseAuth.instance.currentUser != null &&
      NotificationService.instance.isPermissionGranted) {
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
