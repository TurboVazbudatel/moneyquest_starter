
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../models/budget_category.dart';
import '../models/tx_entry.dart';

class Store {
  static const _kChallenges = 'challenges_json';
  static const _kCurrentId = 'current_challenge_id';
  static const _kCategories = 'categories_json';
  static const _kStreak = 'streak_days';
  static const _kStreakLastDay = 'streak_last_day';
  static String _txKey(String challengeId) => 'tx_$challengeId';
  static String _allocKey(String challengeId) => 'alloc_$challengeId';

  static Future<List<Challenge>> loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kChallenges);
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw) as List;
    return data.map((e) => Challenge.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveChallenges(List<Challenge> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kChallenges, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  static Future<String?> getCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCurrentId);
  }

  static Future<void> setCurrentId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_kCurrentId);
    } else {
      await prefs.setString(_kCurrentId, id);
    }
  }

  static Future<List<BudgetCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCategories);
    if (raw == null) {
      final defaults = [
        BudgetCategory(id: 'c_food', name: 'Еда', icon: '🍔'),
        BudgetCategory(id: 'c_transport', name: 'Транспорт', icon: '🚌'),
        BudgetCategory(id: 'c_shopping', name: 'Покупки', icon: '🛍️'),
        BudgetCategory(id: 'c_bills', name: 'Счета', icon: '💡'),
        BudgetCategory(id: 'c_fun', name: 'Развлечения', icon: '🎮'),
        BudgetCategory(id: 'c_other', name: 'Прочее', icon: '📦'),
      ];
      await saveCategories(defaults);
      return defaults;
    }
    final List data = jsonDecode(raw) as List;
    return data.map((e) => BudgetCategory.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveCategories(List<BudgetCategory> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCategories, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  static Future<List<TxEntry>> loadTx(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_txKey(challengeId));
    if (raw == null || raw.isEmpty) return [];
    final List data = jsonDecode(raw) as List;
    return data.map((e) => TxEntry.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveTx(String challengeId, List<TxEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_txKey(challengeId), jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  static Future<Map<String, double>> loadAllocations(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_allocKey(challengeId));
    if (raw == null || raw.isEmpty) return {};
    final Map<String, dynamic> m = jsonDecode(raw);
    return m.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  static Future<void> saveAllocations(String challengeId, Map<String, double> m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_allocKey(challengeId), jsonEncode(m));
  }

  static Future<int> getStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kStreak) ?? 0;
  }

  static Future<DateTime?> getStreakLastDay() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kStreakLastDay);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static Future<void> updateStreakOnNewTx() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = await getStreakLastDay();
    if (last == null) {
      await p.setInt(_kStreak, 1);
      await p.setString(_kStreakLastDay, today.toIso8601String());
      return;
    }
    final lastDay = DateTime(last.year, last.month, last.day);
    final diff = today.difference(lastDay).inDays;
    if (diff == 0) {
      return;
    } else if (diff == 1) {
      final cur = p.getInt(_kStreak) ?? 0;
      await p.setInt(_kStreak, cur + 1);
      await p.setString(_kStreakLastDay, today.toIso8601String());
    } else {
      await p.setInt(_kStreak, 1);
      await p.setString(_kStreakLastDay, today.toIso8601String());
    }
  }

  static Future<void> wipeChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kChallenges);
    await prefs.remove(_kCurrentId);
    await prefs.remove('hist_spend');
    await prefs.remove('current_theme');
    await prefs.remove('current_planned');
    await prefs.remove('current_spend');
    await prefs.remove('current_tx');
  }
}
