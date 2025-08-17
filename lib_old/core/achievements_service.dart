
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';

class AchievementsService {
  static const kFirstStart = 'ach_first_start';
  static const kFirstFinish = 'ach_first_finish';
  static const kThreeChallenges = 'ach_three_challenges';
  static const kSevenDay = 'ach_seven_day_completed';
  static const kScore90 = 'ach_score_90';

  static Future<Map<String, bool>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      kFirstStart: prefs.getBool(kFirstStart) ?? false,
      kFirstFinish: prefs.getBool(kFirstFinish) ?? false,
      kThreeChallenges: prefs.getBool(kThreeChallenges) ?? false,
      kSevenDay: prefs.getBool(kSevenDay) ?? false,
      kScore90: prefs.getBool(kScore90) ?? false,
    };
  }

  static Future<void> considerOnStart(List<Challenge> all) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(kFirstStart) ?? false)) {
      await prefs.setBool(kFirstStart, true);
    }
    if (!(prefs.getBool(kThreeChallenges) ?? false) && all.length >= 3) {
      await prefs.setBool(kThreeChallenges, true);
    }
  }

  static Future<void> considerOnFinish(Challenge c) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(kFirstFinish) ?? false)) {
      await prefs.setBool(kFirstFinish, true);
    }
    if (c.days >= 7 && !(prefs.getBool(kSevenDay) ?? false)) {
      await prefs.setBool(kSevenDay, true);
    }
    if (c.score >= 90 && !(prefs.getBool(kScore90) ?? false)) {
      await prefs.setBool(kScore90, true);
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kFirstStart);
    await prefs.remove(kFirstFinish);
    await prefs.remove(kThreeChallenges);
    await prefs.remove(kSevenDay);
    await prefs.remove(kScore90);
  }
}
