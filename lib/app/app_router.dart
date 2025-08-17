import 'package:flutter/material.dart';
import '../core/guards/lock_gate.dart';
import '../features/home/home_screen.dart';

class AppRouter {
  static const lockGate = '/';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case lockGate:
        return MaterialPageRoute(builder: (_) => const LockGate());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
