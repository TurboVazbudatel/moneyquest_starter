import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/controllers/theme_controller.dart';
import 'core/services/profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await ProfileService.instance.load();
  runApp(const MoneyQuestApp());
}
