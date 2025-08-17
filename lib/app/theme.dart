import 'package:flutter/material.dart';

ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorSchemeSeed: const Color(0xFF2D6A8A),
  cardTheme: const CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);

ThemeData buildDarkTheme() => buildLightTheme().copyWith(
  brightness: Brightness.dark,
);
