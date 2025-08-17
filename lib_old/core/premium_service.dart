
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const _kUntil = 'premium_until_ms';
  static Future<bool> isActive() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_kUntil) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  static Future<Duration> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_kUntil) ?? 0;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: left.clamp(0, 1 << 31).toInt());
  }

  static Future<void> startTrial3Days() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch;
    await prefs.setInt(_kUntil, until);
  }

  static Future<void> extendBy14Days() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = prefs.getInt(_kUntil) ?? now;
    final base = current > now ? current : now;
    final until = base + const Duration(days: 14).inMilliseconds;
    await prefs.setInt(_kUntil, until);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUntil);
  }
}
