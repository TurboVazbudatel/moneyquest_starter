
import 'package:flutter/material.dart';
import 'core/theme_controller.dart';
import 'core/profile_service.dart';
import 'screens/lock_gate.dart';

class MoneyQuestApp extends StatelessWidget {
  const MoneyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeController.instance, ProfileService.instance]),
      builder: (context, _) {
        return MaterialApp(
          title: 'MoneyQuest',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeController.instance.mode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2D6A8A),
            cardTheme: const CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2D6A8A),
            cardTheme: const CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
          ),
          home: const LockGate(),
        );
      },
    );
  }
}
