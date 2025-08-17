
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._();
  ProfileService._();

  static const _kFirstRunDone = 'first_run_done';
  static const _kNick = 'profile_nick';
  static const _kGender = 'profile_gender'; // m/f
  static const _kCurrency = 'profile_currency'; // "₽" | "$" | "€"
  static const _kPoints = 'profile_points';

  bool firstRunDone = false;
  String nick = 'Путешественник';
  String gender = 'f';
  String currency = '₽';
  int points = 0;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    firstRunDone = p.getBool(_kFirstRunDone) ?? false;
    nick = p.getString(_kNick) ?? 'Путешественник';
    gender = p.getString(_kGender) ?? 'f';
    currency = p.getString(_kCurrency) ?? '₽';
    points = p.getInt(_kPoints) ?? 0;
    notifyListeners();
  }

  Future<void> completeFirstRun({required String n, required String g, required String cur}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kFirstRunDone, true);
    await p.setString(_kNick, n);
    await p.setString(_kGender, g);
    await p.setString(_kCurrency, cur);
    firstRunDone = true;
    nick = n;
    gender = g;
    currency = cur;
    notifyListeners();
  }

  Future<void> addPoints(int v) async {
    points += v;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kPoints, points);
    notifyListeners();
  }
}
