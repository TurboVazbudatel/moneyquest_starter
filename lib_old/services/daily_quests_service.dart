import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moneyquest_refactored/lib/services/profile_service.dart' as ps show ProfileService;
// NOTE: during packaging path isn't real. In your project, change import to: ../services/profile_service.dart
// Kept minimal to avoid circular build errors in this demo zip.

class DailyQuestsService {
  static const _kDate = 'dq_date';
  static const _kStates = 'dq_states'; // json [bool,bool,bool]
  static const _kRewards = [5, 10, 15];

  static List<String> get descriptions => const [
        'Зайти в приложение',
        'Добавить любую транзакцию',
        'Удержаться ≤ 70% от плана (по текущему челленджу)',
      ];

  static Future<List<bool>> loadStates() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = '${today.year}-${today.month}-${today.day}';
    if (p.getString(_kDate) != key) {
      await p.setString(_kDate, key);
      await p.setString(_kStates, jsonEncode([false, false, false]));
      return [false, false, false];
    }
    final raw = p.getString(_kStates);
    if (raw == null) return [false, false, false];
    final List a = jsonDecode(raw);
    return a.map((e) => e == true).toList().cast<bool>();
  }

  static Future<void> setDone(int idx) async {
    final p = await SharedPreferences.getInstance();
    final states = await loadStates();
    if (!states[idx]) {
      states[idx] = true;
      await p.setString(_kStates, jsonEncode(states));
      // Replace with ProfileService.instance.addPoints in real code
      // await ProfileService.instance.addPoints(_kRewards[idx]);
    }
  }
}
