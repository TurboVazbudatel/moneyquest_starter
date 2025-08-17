import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  static const _kThemeMode = 'theme_mode'; // 0: light, 1: dark, 2: system
  ThemeMode mode = ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final i = prefs.getInt(_kThemeMode);
    switch (i) {
      case 0:
        mode = ThemeMode.light;
        break;
      case 1:
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> set(ThemeMode m) async {
    mode = m;
    final prefs = await SharedPreferences.getInstance();
    final i = m == ThemeMode.light ? 0 : (m == ThemeMode.dark ? 1 : 2);
    await prefs.setInt(_kThemeMode, i);
    notifyListeners();
  }
}
