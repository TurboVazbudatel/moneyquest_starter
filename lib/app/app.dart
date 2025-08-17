import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_router.dart';
import '../core/controllers/theme_controller.dart';
import '../core/services/profile_service.dart';

class MoneyQuestApp extends StatelessWidget {
  const MoneyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeController.instance, ProfileService.instance]),
      builder: (_, __) => MaterialApp(
        title: 'MoneyQuest',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeController.instance.mode,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.lockGate,
      ),
    );
  }
}
