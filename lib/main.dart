import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* ============================ APP ENTRY ============================ */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await ProfileService.instance.load();
  runApp(const MoneyQuestApp());
}

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

/* ============================ THEME CTRL =========================== */

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

/* =========================== PROFILE / ONBOARD ====================== */

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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nickCtrl = TextEditingController(text: 'AiriFan');
  String gender = 'f';
  String currency = '₽';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ник'),
              subtitle: TextField(
                controller: nickCtrl,
                decoration: const InputDecoration(hintText: 'например, AiriFan'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wc),
              title: const Text('Пол аватара'),
              subtitle: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: const Text('Женский'), selected: gender == 'f', onSelected: (_) => setState(() => gender = 'f')),
                  ChoiceChip(label: const Text('Мужской'), selected: gender == 'm', onSelected: (_) => setState(() => gender = 'm')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Валюта'),
              subtitle: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: const Text('₽'), selected: currency == '₽', onSelected: (_) => setState(() => currency = '₽')),
                  ChoiceChip(label: const Text('\$'), selected: currency == '\$', onSelected: (_) => setState(() => currency = '\$')),
                  ChoiceChip(label: const Text('€'), selected: currency == '€', onSelected: (_) => setState(() => currency = '€')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Готово'),
            onPressed: () async {
              final n = nickCtrl.text.trim().isEmpty ? 'AiriFan' : nickCtrl.text.trim();
              await ProfileService.instance.completeFirstRun(n: n, g: gender, cur: currency);
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
          )
        ],
      ),
    );
  }
}

/* ========================== MODELS & STORAGE ========================== */

class Challenge {
  final String id;
  final String theme;
  final int days;
  final double planned;
  final double spend;
  final int tx;
  final int createdAtMs;

  Challenge({
    required this.id,
    required this.theme,
    required this.days,
    required this.planned,
    required this.spend,
    required this.tx,
    required this.createdAtMs,
  });

  Challenge copyWith({String? id, String? theme, int? days, double? planned, double? spend, int? tx, int? createdAtMs}) {
    return Challenge(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      days: days ?? this.days,
      planned: planned ?? this.planned,
      spend: spend ?? this.spend,
      tx: tx ?? this.tx,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'theme': theme,
        'days': days,
        'planned': planned,
        'spend': spend,
        'tx': tx,
        'createdAtMs': createdAtMs,
      };

  static Challenge fromMap(Map<String, dynamic> m) => Challenge(
        id: m['id'] as String,
        theme: m['theme'] as String,
        days: (m['days'] as num).toInt(),
        planned: (m['planned'] as num).toDouble(),
        spend: (m['spend'] as num).toDouble(),
        tx: (m['tx'] as num).toInt(),
        createdAtMs: (m['createdAtMs'] as num).toInt(),
      );

  double get score {
    if (planned <= 0) return 0;
    final raw = (planned - spend) / planned;
    final s = (raw < 0 ? 0 : raw) * 100.0;
    return double.parse(s.toStringAsFixed(1));
  }
}

class BudgetCategory {
  final String id;
  final String name;
  final String icon; // emoji
  BudgetCategory({required this.id, required this.name, required this.icon});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon': icon};
  static BudgetCategory fromMap(Map<String, dynamic> m) =>
      BudgetCategory(id: m['id'], name: m['name'], icon: m['icon']);
}

class TxEntry {
  final String id;
  final String challengeId;
  final String categoryId;
  final double amount;
  final String note;
  final int tsMs;

  TxEntry({
    required this.id,
    required this.challengeId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.tsMs,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'challengeId': challengeId,
        'categoryId': categoryId,
        'amount': amount,
        'note': note,
        'tsMs': tsMs,
      };

  static TxEntry fromMap(Map<String, dynamic> m) => TxEntry(
        id: m['id'],
        challengeId: m['challengeId'],
        categoryId: m['categoryId'],
        amount: (m['amount'] as num).toDouble(),
        note: m['note'],
        tsMs: (m['tsMs'] as num).toInt(),
      );
}

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

/* ========================== PREMIUM / TRIAL ========================== */

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

/* ======================== ACHIEVEMENTS SERVICE ======================= */

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

/* ============================ LOCK (PIN) ============================ */

class LockService {
  static const _kPin = 'app_pin';
  static const _kPinEnabled = 'pin_enabled';
  static bool _sessionUnlocked = false;

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kPinEnabled) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPinEnabled, v);
    if (!v) _sessionUnlocked = true;
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPin, pin);
  }

  static Future<bool> verify(String pin) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getString(_kPin);
    final ok = (cur != null && cur == pin);
    if (ok) _sessionUnlocked = true;
    return ok;
  }

  static bool get isSessionUnlocked => _sessionUnlocked;
}

class LockGate extends StatefulWidget {
  const LockGate({super.key});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final enabled = await LockService.isEnabled();
    if (!enabled || LockService.isSessionUnlocked) {
      if (!mounted) return;
      if (!ProfileService.instance.firstRunDone) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: LockService.isEnabled(),
      builder: (ctx, snap) {
        final enabled = snap.data ?? false;
        if (!enabled || LockService.isSessionUnlocked) {
          return ProfileService.instance.firstRunDone ? const HomeScreen() : const OnboardingScreen();
        }
        return const PinLockScreen();
      },
    );
  }
}

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});
  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final ctrl = TextEditingController();
  String err = '';
  Future<void> _submit() async {
    final ok = await LockService.verify(ctrl.text);
    if (ok && mounted) {
      if (!ProfileService.instance.firstRunDone) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      setState(() => err = 'Неверный PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Введите PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Для входа в приложение введите 4-значный PIN'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••'),
            ),
            if (err.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(err, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Войти')),
          ],
        ),
      ),
    );
  }
}

/* ============================== HOME =============================== */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool premium = false;
  Duration left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _refreshPremium();
  }

  Future<void> _refreshPremium() async {
    final a = await PremiumService.isActive();
    final r = await PremiumService.remaining();
    setState(() {
      premium = a;
      left = r;
    });
  }

  Future<void> _startTrial() async {
    await PremiumService.startTrial3Days();
    await _refreshPremium();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Премиум-триал активирован на 3 дня')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = left.inDays;
    final h = left.inHours % 24;
    final nick = ProfileService.instance.nick;
    final pts = ProfileService.instance.points;

    return Scaffold(
      appBar: AppBar(
        title: Text('MoneyQuest — $nick'),
        actions: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(children: [
              const Icon(Icons.stars, size: 20),
              const SizedBox(width: 4),
              Text('$pts'),
            ]),
          )),
          IconButton(
            tooltip: 'Ачивки',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
          ),
          IconButton(
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: premium ? Colors.green.withOpacity(.08) : Colors.amber.withOpacity(.12),
            child: ListTile(
              leading: Icon(premium ? Icons.verified : Icons.workspace_premium),
              title: Text(premium ? 'Премиум активен' : 'Премиум 3 дня бесплатно'),
              subtitle: Text(
                premium
                    ? 'Осталось: ${d}д ${h}ч · Открыт Ghost Mode и 7-дневные челленджи'
                    : 'Ghost Mode, 7-дневные челленджи и ИИ-подсказки',
              ),
              trailing: premium ? const Icon(Icons.check) : FilledButton(onPressed: _startTrial, child: const Text('Активировать')),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Ежедневные квесты'),
              subtitle: const Text('Выполняй задания и получай очки'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyQuestsScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Дашборд'),
              subtitle: const Text('Баланс, прогресс, серия дней'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Недельный отчёт'),
              subtitle: const Text('Итоги за последние 7 дней'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklySummaryScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('ФинВикторина'),
              subtitle: const Text('Проверь знания, получи очки'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceQuizScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('AI Tips'),
              subtitle: const Text('Персональные подсказки по данным'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AITipsScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.face_retouching_natural),
              title: const Text('Аватар-студия'),
              subtitle: const Text('1 раз бесплатно, расширено в Премиуме'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvatarStudioScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sports_martial_arts),
              title: const Text('Solo Arena (демо)'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoloStartScreen())),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Планировщик бюджета'),
              subtitle: const Text('Лимиты по категориям на текущий челлендж'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPlannerScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Категории бюджета'),
              subtitle: const Text('Добавляй и редактируй категории'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Транзакции'),
              subtitle: const Text('По текущему челленджу'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Графики'),
              subtitle: const Text('Категории + 7 дней'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartsScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Мои челленджи'),
              subtitle: const Text('Список активных и завершённых'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Ghost Mode (призрак)'),
              subtitle: const Text('Соревнование с «призраком» (Премиум)'),
              onTap: () async {
                final active = await PremiumService.isActive();
                if (!active && mounted) {
                  _showNeedPremium(context);
                } else {
                  if (mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const GhostModeScreen()));
                  }
                }
              },
              trailing: Icon(premium ? Icons.lock_open : Icons.lock),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Реферал-код'),
              subtitle: const Text('Введи код — получи +14 дней Премиума'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen())),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Лидерборд (моки)'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }

  void _showNeedPremium(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Нужен Премиум'),
        content: const Text('Функция доступна в премиум-подписке. Включить 3-дневный триал?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Нет')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await PremiumService.startTrial3Days();
              await _refreshPremium();
            },
            child: const Text('Активировать'),
          ),
        ],
      ),
    );
  }
}

/* ========================== DAILY QUESTS =========================== */

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
      await ProfileService.instance.addPoints(_kRewards[idx]);
    }
  }
}

class DailyQuestsScreen extends StatefulWidget {
  const DailyQuestsScreen({super.key});
  @override
  State<DailyQuestsScreen> createState() => _DailyQuestsScreenState();
}

class _DailyQuestsScreenState extends State<DailyQuestsScreen> {
  List<bool> states = const [false, false, false];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await DailyQuestsService.loadStates();
    if (mounted) setState(() => states = s);
    await DailyQuestsService.setDone(0);
    final s2 = await DailyQuestsService.loadStates();
    if (mounted) setState(() => states = s2);
  }

  @override
  Widget build(BuildContext context) {
    final d = DailyQuestsService.descriptions;
    return Scaffold(
      appBar: AppBar(title: const Text('Ежедневные квесты')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, i) {
          final done = states[i];
          final reward = DailyQuestsService._kRewards[i];
          return Card(
            child: ListTile(
              leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : null),
              title: Text(d[i]),
              subtitle: Text('Награда: +$reward очков'),
              trailing: done ? const Text('Выполнено') : null,
            ),
          );
        },
      ),
    );
  }
}

/* ========================== SOLO ARENA ============================= */

class SoloStartScreen extends StatefulWidget {
  const SoloStartScreen({super.key});
  @override
  State<SoloStartScreen> createState() => _SoloStartScreenState();
}

class _SoloStartScreenState extends State<SoloStartScreen> {
  String themeCode = 'Экономия на еде';
  int duration = 1; // 1/3/7
  double limit = 1000;

  Future<void> _pickDuration(int d) async {
    if (d == 7) {
      final ok = await PremiumService.isActive();
      if (!ok && mounted) {
        _askStartTrialFor7();
        return;
      }
    }
    setState(() => duration = d);
  }

  void _askStartTrialFor7() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('7 дней — Премиум'),
        content: const Text('7-дневные челленджи доступны с премиумом. Включить бесплатный триал?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await PremiumService.startTrial3Days();
              setState(() {});
            },
            child: const Text('Активировать'),
          ),
        ],
      ),
    );
  }

  Future<void> _startChallenge() async {
    final list = await Store.loadChallenges();
    final id = 'ch_${DateTime.now().millisecondsSinceEpoch}';
    final ch = Challenge(
      id: id,
      theme: themeCode,
      days: duration,
      planned: limit,
      spend: 0,
      tx: 0,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    list.add(ch);
    await Store.saveChallenges(list);
    await Store.setCurrentId(id);
    await AchievementsService.considerOnStart(list);

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SoloProgressScreen(challengeId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final cur = ProfileService.instance.currency;
    return Scaffold(
      appBar: AppBar(title: const Text('Solo Arena — старт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Тема челленджа'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: themeCode,
              items: const [
                DropdownMenuItem(value: 'Экономия на еде', child: Text('Экономия на еде')),
                DropdownMenuItem(value: 'Без импульсивных покупок', child: Text('Без импульсивных покупок')),
                DropdownMenuItem(value: 'Мин. трат на транспорт', child: Text('Мин. трат на транспорт')),
              ],
              onChanged: (v) => setState(() => themeCode = v!),
            ),
            const SizedBox(height: 16),
            const Text('Длительность'),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: PremiumService.isActive(),
              builder: (context, snap) {
                final prem = snap.data ?? false;
                return Wrap(
                  spacing: 8,
                  children: [1, 3, 7].map((d) {
                    final isSelected = d == duration;
                    final locked = (d == 7 && !prem);
                    final label = d == 7 ? '7 дней (Премиум)' : '$d дн.';
                    return ChoiceChip(
                      label: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(label),
                        if (locked) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.lock, size: 16))
                      ]),
                      selected: isSelected,
                      onSelected: (_) => _pickDuration(d),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Плановый лимит ($cur)'),
            Slider(
              min: 300.0, // <-- double
              max: 10000.0, // <-- double
              divisions: 97,
              value: limit,
              label: limit.toStringAsFixed(0),
              onChanged: (v) => setState(() => limit = v),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Начать'),
              onPressed: _startChallenge,
            ),
          ],
        ),
      ),
    );
  }
}

class SoloProgressScreen extends StatefulWidget {
  final String challengeId;
  const SoloProgressScreen({super.key, required this.challengeId});
  @override
  State<SoloProgressScreen> createState() => _SoloProgressScreenState();
}

class _SoloProgressScreenState extends State<SoloProgressScreen> {
  static const String curSym = '₽'; // символ валюты
  Challenge? ch;

  @override
  void initState() {
    super.initState();
    _load();
  }

  double get score => ch?.score ?? 0;

  Future<void> _load() async {
    final list = await Store.loadChallenges();
    final found = list.where((e) => e.id == widget.challengeId).toList();
    if (!mounted) return;
    setState(() => ch = found.isNotEmpty ? found.first : null);

    if (ch != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_theme', ch!.theme);
      await prefs.setDouble('current_planned', ch!.planned);
      await prefs.setInt('current_tx', ch!.tx);
      final txs = await Store.loadTx(ch!.id);
      final total = txs.fold<double>(0.0, (s, t) => s + t.amount);
      await prefs.setDouble('current_spend', total);

      final hist = List<double>.from(prefs.getStringList('hist_spend')?.map(double.parse) ?? []);
      List<double> updated;
      if (hist.isEmpty) {
        updated = List<double>.generate(
          7,
          (i) => (total * (0.5 + i / 14)).clamp(0.0, ch!.planned).toDouble(),
        );
      } else {
        updated = [...hist, total];
        if (updated.length > 7) updated = updated.sublist(updated.length - 7);
      }
      await prefs.setStringList('hist_spend', updated.map((e) => e.toString()).toList());

      final challenges = await Store.loadChallenges();
      final idx = challenges.indexWhere((e) => e.id == ch!.id);
      if (idx >= 0) {
        challenges[idx] = challenges[idx].copyWith(spend: total, tx: txs.length);
        await Store.saveChallenges(challenges);
        setState(() => ch = challenges[idx]);
      }

      if (total <= ch!.planned * 0.7) {
        await DailyQuestsService.setDone(2);
      }
    }
  }

  Future<void> _addTx(double amount) async {
    if (ch == null) return;
    final txs = await Store.loadTx(ch!.id);
    final entry = TxEntry(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      challengeId: ch!.id,
      categoryId: 'c_other',
      amount: amount,
      note: 'Быстрое добавление',
      tsMs: DateTime.now().millisecondsSinceEpoch,
    );
    txs.add(entry);
    await Store.saveTx(ch!.id, txs);
    await Store.updateStreakOnNewTx();
    await DailyQuestsService.setDone(1);
    await _load();
  }

  Future<void> _reset() async {
    if (ch == null) return;
    await Store.saveTx(ch!.id, []);
    final challenges = await Store.loadChallenges();
    final idx = challenges.indexWhere((e) => e.id == ch!.id);
    if (idx >= 0) {
      challenges[idx] = challenges[idx].copyWith(spend: 0, tx: 0);
      await Store.saveChallenges(challenges);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_theme');
    await prefs.remove('current_planned');
    await prefs.remove('current_spend');
    await prefs.remove('current_tx');
    await prefs.remove('hist_spend');
    if (mounted) setState(() => ch = challenges[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final c = ch;
    if (c == null) {
      return Scaffold(appBar: AppBar(title: const Text('Прогресс челленджа')), body: const Center(child: Text('Челлендж не найден')));
    }
    final cur = ProfileService.instance.currency;

    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс челленджа')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Тема: ${c.theme} · Длительность: ${c.days} д.'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: ((c.score / 100).clamp(0.0, 1.0)).toDouble()),
          const SizedBox(height: 8),
          Text('Savings Score: ${c.score.toStringAsFixed(1)}%'),
          Text('План: $cur${c.planned.toStringAsFixed(0)} · Траты: $cur${c.spend.toStringAsFixed(0)} · Транзакций: ${c.tx}'),
          const Spacer(),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _addTx(150),  child: Text('+ ${curSym}150'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _addTx(500),  child: Text('+ ${curSym}500'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _addTx(1000), child: Text('+ ${curSym}1000'))),
          ]),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await AchievementsService.considerOnFinish(c);
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SoloResultScreen(challenge: c)));
            },
            child: const Text('Завершить челлендж'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _reset, child: const Text('Сбросить прогресс')),
        ]),
      ),
    );
  }
}

/* ============================ RESULTS ============================== */

class SoloResultScreen extends StatelessWidget {
  final Challenge challenge;
  const SoloResultScreen({super.key, required this.challenge});

  String _buildCsv(Challenge c) {
    final b = StringBuffer();
    b.writeln('Field,Value');
    b.writeln('Theme,${c.theme}');
    b.writeln('Days,${c.days}');
    b.writeln('Planned,${c.planned.toStringAsFixed(2)}');
    b.writeln('Spend,${c.spend.toStringAsFixed(2)}');
    b.writeln('Tx,${c.tx}');
    b.writeln('SavingsScore,${c.score.toStringAsFixed(1)}%');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final score = challenge.score;
    final cur = ProfileService.instance.currency;
    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Savings Score: ${score.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Тема: ${challenge.theme} · Дни: ${challenge.days}'),
          Text('План: $cur${challenge.planned.toStringAsFixed(0)} · Траты: $cur${challenge.spend.toStringAsFixed(0)} · Транзакций: ${challenge.tx}'),
          const Spacer(),
          Wrap(spacing: 12, runSpacing: 12, children: [
            OutlinedButton(
              onPressed: () async {
                final text = 'MoneyQuest · Результат: ${score.toStringAsFixed(1)}% '
                    '(Тема: ${challenge.theme}, план $cur${challenge.planned.toStringAsFixed(0)}, '
                    'траты $cur${challenge.spend.toStringAsFixed(0)})';
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано в буфер обмена')));
                }
              },
              child: const Text('Поделиться'),
            ),
            OutlinedButton(
              onPressed: () async {
                final csv = _buildCsv(challenge);
                await Clipboard.setData(ClipboardData(text: csv));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV скопирован в буфер обмена')));
                }
              },
              child: const Text('Экспорт CSV'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              child: const Text('К лидерборду'),
            ),
            FilledButton(
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false),
              child: const Text('На главную'),
            ),
          ]),
        ]),
      ),
    );
  }
}

/* ============================ DASHBOARD ============================ */

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Challenge? current;
  bool premium = false;
  List<double> history = const [];
  int streak = 0;
  double get score => current?.score ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    final prem = await PremiumService.isActive();
    final s = await Store.getStreak();
    Challenge? c;
    if (currentId != null) {
      for (final e in list) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getStringList('hist_spend')?.map(double.parse).toList() ?? <double>[];
    if (mounted) {
      setState(() {
        current = c;
        premium = prem;
        history = h;
        streak = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = current != null;
    final color = Theme.of(context).colorScheme.primary;
    final cur = ProfileService.instance.currency;

    return Scaffold(
      appBar: AppBar(title: const Text('Дашборд')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hasActive
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!premium)
                  Card(
                      color: Colors.amber.withOpacity(.12),
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium),
                        title: const Text('Премиум 3 дня бесплатно'),
                        subtitle: const Text('Откройте 7-дневные челленджи и Ghost Mode'),
                        trailing: FilledButton(onPressed: () async {
                          await PremiumService.startTrial3Days();
                          await _load();
                        }, child: const Text('Активировать')),
                      )),
                Text('Текущий челлендж: ${current!.theme}'),
                const SizedBox(height: 12),
                Center(
                    child: SizedBox(
                        height: 140,
                        width: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(value: ((score / 100).clamp(0.0, 1.0)).toDouble(), strokeWidth: 10),
                            Text('${score.toStringAsFixed(1)}%'),
                          ],
                        ))),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Text('План: $cur${current!.planned.toStringAsFixed(0)}')),
                  Expanded(child: Text('Траты: $cur${current!.spend.toStringAsFixed(0)}')),
                ]),
                Text('Транзакций: ${current!.tx}'),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                  const SizedBox(width: 6),
                  Text('Серия дней: $streak'),
                ]),
                const SizedBox(height: 16),
                if (history.isNotEmpty)
                  Card(
                      child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(height: 70, child: CustomPaint(painter: SparklinePainter(history, color))),
                  )),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.sports_martial_arts),
                  label: const Text('Продолжить челлендж'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SoloProgressScreen(challengeId: current!.id)));
                  },
                )
              ])
            : _emptyState(context),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.hourglass_empty, size: 64),
      const SizedBox(height: 12),
      const Text('Пока активного челленджа нет'),
      const SizedBox(height: 12),
      FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoloStartScreen())), child: const Text('Начать новый')),
    ]));
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  SparklinePainter(this.points, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minV = points.reduce(math.min);
    final maxV = points.reduce(math.max);
    final span = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);
    final dx = points.length > 1 ? size.width / (points.length - 1) : size.width;
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = points.length > 1 ? i.toDouble() * dx : size.width / 2;
      final y = size.height - ((points[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter old) => old.points != points || old.color != color;
}

/* ============================ BUDGET PLANNER ======================== */

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});
  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  Challenge? current;
  List<BudgetCategory> cats = [];
  Map<String, double> alloc = {};
  Map<String, double> spentByCat = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final challenges = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    Challenge? c;
    if (currentId != null) {
      for (final e in challenges) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }
    final categories = await Store.loadCategories();
    final m = c == null ? <String, double>{} : await Store.loadAllocations(c.id);
    final txs = c == null ? <TxEntry>[] : await Store.loadTx(c.id);
    final byCat = <String, double>{};
    for (final t in txs) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0.0) + t.amount;
    }

    if (mounted) {
      setState(() {
        current = c;
        cats = categories;
        alloc = m;
        spentByCat = byCat;
      });
    }
  }

  double _sumAlloc() => alloc.values.fold(0.0, (s, v) => s + v);

  Future<void> _editAlloc(BudgetCategory c) async {
    final ctrl = TextEditingController(text: (alloc[c.id] ?? 0).toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Лимит для ${c.icon} ${c.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Сумма'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
        ],
      ),
    );
    if (ok != true || current == null) return;
    final v = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0;
    alloc[c.id] = v < 0 ? 0.0 : v;
    await Store.saveAllocations(current!.id, alloc);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cur = ProfileService.instance.currency;
    if (current == null) {
      return Scaffold(appBar: AppBar(title: const Text('Планировщик бюджета')), body: const Center(child: Text('Нет текущего челленджа. Создайте в Solo Arena.')));
    }
    final sumAlloc = _sumAlloc();
    final warn = sumAlloc > current!.planned;

    return Scaffold(
      appBar: AppBar(title: const Text('Планировщик бюджета')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Общий план: $cur${current!.planned.toStringAsFixed(0)}'),
          Row(children: [
            Expanded(child: Text('Сумма лимитов: $cur${sumAlloc.toStringAsFixed(0)}')),
            if (warn) const Text('Превышение!', style: TextStyle(color: Colors.red)),
          ]),
          const SizedBox(height: 12),
          ...cats.map((c) {
            final lim = alloc[c.id] ?? 0;
            final spent = spentByCat[c.id] ?? 0;
            final double left = (lim - spent).clamp(0.0, double.infinity).toDouble();
            final double ratio = lim <= 0 ? 0.0 : (spent / lim).clamp(0.0, 1.0).toDouble();
            return Card(
              child: ListTile(
                leading: Text(c.icon, style: const TextStyle(fontSize: 24)),
                title: Text('${c.name} · лимит: $cur${lim.toStringAsFixed(0)}'),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  LinearProgressIndicator(value: ratio),
                  const SizedBox(height: 4),
                  Text('Потрачено: $cur${spent.toStringAsFixed(0)} · Остаток: $cur${left.toStringAsFixed(0)}'),
                ]),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _editAlloc(c)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* ============================ CATEGORIES =========================== */

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<BudgetCategory> cats = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await Store.loadCategories();
    if (mounted) setState(() => cats = list);
  }

  Future<void> _addCategory() async {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController(text: '🧩');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая категория'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 8),
          TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Иконка (эмодзи)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Добавить')),
        ],
      ),
    );
    if (ok != true) return;
    final name = nameCtrl.text.trim();
    final icon = iconCtrl.text.trim().isEmpty ? '🧩' : iconCtrl.text.trim();
    if (name.isEmpty) return;
    cats.add(BudgetCategory(id: 'c_${DateTime.now().millisecondsSinceEpoch}', name: name, icon: icon));
    await Store.saveCategories(cats);
    if (mounted) setState(() {});
  }

  Future<void> _editCategory(BudgetCategory c) async {
    final nameCtrl = TextEditingController(text: c.name);
    final iconCtrl = TextEditingController(text: c.icon);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать категорию'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 8),
          TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Иконка (эмодзи)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
        ],
      ),
    );
    if (ok != true) return;
    final idx = cats.indexWhere((e) => e.id == c.id);
    if (idx >= 0) {
      cats[idx] = BudgetCategory(id: c.id, name: nameCtrl.text.trim(), icon: iconCtrl.text.trim());
      await Store.saveCategories(cats);
      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteCategory(BudgetCategory c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('«${c.name}» будет удалена. Транзакции сохранятся с её ID.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (ok != true) return;
    cats.removeWhere((e) => e.id == c.id);
    await Store.saveCategories(cats);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории бюджета'), actions: [
        IconButton(onPressed: _addCategory, icon: const Icon(Icons.add)),
      ]),
      body: ListView.separated(
        itemCount: cats.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = cats[i];
          return ListTile(
            leading: Text(c.icon, style: const TextStyle(fontSize: 24)),
            title: Text(c.name),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () => _editCategory(c), icon: const Icon(Icons.edit)),
              IconButton(onPressed: () => _deleteCategory(c), icon: const Icon(Icons.delete_outline)),
            ]),
          );
        },
      ),
    );
  }
}

/* ============================ TRANSACTIONS ========================== */

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  Challenge? current;
  List<BudgetCategory> cats = [];
  List<TxEntry> txs = [];
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final challenges = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    final categories = await Store.loadCategories();
    Challenge? c;
    if (currentId != null) {
      for (final e in challenges) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }
    final t = c == null ? <TxEntry>[] : await Store.loadTx(c.id);
    if (mounted) {
      setState(() {
        current = c;
        cats = categories;
        txs = t..sort((a, b) => b.tsMs.compareTo(a.tsMs));
      });
    }
  }

  Future<void> _addTxDialog() async {
    if (current == null) return;
    BudgetCategory? selected = cats.isNotEmpty ? cats.first : null;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая транзакция'),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<BudgetCategory>(
            value: selected,
            items: cats.map((c) => DropdownMenuItem(value: c, child: Text('${c.icon} ${c.name}'))).toList(),
            onChanged: (v) => selected = v,
            decoration: const InputDecoration(labelText: 'Категория'),
          ),
          const SizedBox(height: 8),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Сумма')),
          const SizedBox(height: 8),
          TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Заметка (опционально)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Добавить')),
        ],
      ),
    );
    if (ok != true || selected == null) return;

    final sel = selected!;
    final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) return;

    final entry = TxEntry(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      challengeId: current!.id,
      categoryId: sel.id,
      amount: amount,
      note: noteCtrl.text.trim(),
      tsMs: DateTime.now().millisecondsSinceEpoch,
    );
    final all = await Store.loadTx(current!.id);
    all.add(entry);
    await Store.saveTx(current!.id, all);
    await Store.updateStreakOnNewTx();
    final sum = all.fold<double>(0.0, (s, t) => s + t.amount);
    final challenges = await Store.loadChallenges();
    final idx = challenges.indexWhere((e) => e.id == current!.id);
    if (idx >= 0) {
      challenges[idx] = challenges[idx].copyWith(spend: sum, tx: all.length);
      await Store.saveChallenges(challenges);
    }
    await _loadAll();
  }

  String _catName(String id) {
    final c = cats.where((e) => e.id == id).toList();
    return c.isNotEmpty ? '${c.first.icon} ${c.first.name}' : 'Категория $id';
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Scaffold(appBar: AppBar(title: const Text('Транзакции')), body: const Center(child: Text('Нет текущего челленджа. Создайте в Solo Arena.')));
    }
    final cur = ProfileService.instance.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзакции'),
        actions: [IconButton(onPressed: _addTxDialog, icon: const Icon(Icons.add))],
      ),
      body: ListView.separated(
        itemCount: txs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final t = txs[i];
          return ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('$cur${t.amount.toStringAsFixed(0)} — ${_catName(t.categoryId)}'),
            subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(t.tsMs).toLocal().toString().split('.').first + (t.note.isNotEmpty ? '\n${t.note}' : ''),
            ),
          );
        },
      ),
    );
  }
}

/* ============================== CHARTS ============================== */

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});
  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  Challenge? current;
  List<BudgetCategory> cats = [];
  List<TxEntry> txs = [];
  List<double> history = const [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final challenges = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    Challenge? c;
    if (currentId != null) {
      for (final e in challenges) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }
    final categories = await Store.loadCategories();
    final t = c == null ? <TxEntry>[] : await Store.loadTx(c.id);
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getStringList('hist_spend')?.map(double.parse).toList() ?? <double>[];
    if (mounted) setState(() {
      current = c;
      cats = categories;
      txs = t;
      history = h;
    });
  }

  Map<String, double> _spendByCat() {
    final m = <String, double>{};
    for (final t in txs) {
      m[t.categoryId] = (m[t.categoryId] ?? 0.0) + t.amount;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Scaffold(appBar: AppBar(title: const Text('Графики')), body: const Center(child: Text('Нет текущего челленджа. Создайте в Solo Arena.')));
    }
    final byCat = _spendByCat();
    final total = byCat.values.fold(0.0, (s, v) => s + v);

    return Scaffold(
      appBar: AppBar(title: const Text('Графики')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('По категориям (пирог)'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: PieChartPainter(byCat, cats),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: ListView(
                          shrinkWrap: true,
                          children: byCat.entries.map((e) {
                            final cat = cats.firstWhere((c) => c.id == e.key, orElse: () => BudgetCategory(id: e.key, name: 'Категория', icon: '📦'));
                            final p = total > 0 ? (e.value / total * 100).toStringAsFixed(0) : '0';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${cat.icon} ${cat.name} — $p%'),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('7 дней (столбцы)'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: BarsChartPainter(history),
                    child: const SizedBox.expand(),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> byCat;
  final List<BudgetCategory> cats;
  PieChartPainter(this.byCat, this.cats);

  @override
  void paint(Canvas canvas, Size size) {
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    if (total <= 0) {
      final paint = Paint()..color = Colors.grey.withOpacity(.2);
      canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2.4, paint);
      return;
    }
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: size.shortestSide * 0.9, height: size.shortestSide * 0.9);
    double start = -math.pi / 2;
    final rnd = math.Random(42);
    for (final e in byCat.entries) {
      final sweep = (e.value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = HSVColor.fromAHSV(1.0, (rnd.nextDouble() * 360.0), 0.55, 0.85).toColor();
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
    // (опционально можно нарисовать "дырку", если хочешь вид доната)
    // final holePaint = Paint()..color = Colors.white.withOpacity(1.0);
    // canvas.drawCircle(size.center(Offset.zero), size.shortestSide * 0.28, holePaint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) => old.byCat != byCat;
}

class BarsChartPainter extends CustomPainter {
  final List<double> history;
  BarsChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    final maxV = history.reduce(math.max);
    final barW = size.width / (history.length * 1.6);
    final gap = barW * 0.6;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blueGrey;

    for (int i = 0; i < history.length; i++) {
      final v = history[i];
      final h = maxV <= 0 ? 0.0 : (v / maxV) * size.height;
      final left = i.toDouble() * (barW + gap);
      final rect = Rect.fromLTWH(left, size.height - h, barW, h);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BarsChartPainter old) => old.history != history;
}

/* ============================== GHOST MODE ============================== */

class GhostModeScreen extends StatefulWidget {
  const GhostModeScreen({super.key});
  @override
  State<GhostModeScreen> createState() => _GhostModeScreenState();
}

class _GhostModeScreenState extends State<GhostModeScreen> {
  Challenge? current;
  Challenge? ghost; // лучший прошлый
  double mySpend = 0.0;
  double ghostSpend = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final challenges = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    Challenge? c;
    if (currentId != null) {
      for (final e in challenges) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }

    Challenge? best;
    if (c != null) {
      for (final e in challenges) {
        if (e.id == c.id) continue;
        if (e.days == c.days && e.theme == c.theme) {
          if (best == null || e.score > best!.score) best = e;
        }
      }
    }
    best ??= c == null ? null : c.copyWith(id: 'ghost', spend: c.planned * 0.15);

    double ms = 0.0;
    if (c != null) {
      final tx = await Store.loadTx(c.id);
      ms = tx.fold<double>(0.0, (s, t) => s + t.amount);
    }
    final double gs = best == null ? 0.0 : best.spend;

    if (mounted) setState(() {
      current = c;
      ghost = best;
      mySpend = ms;
      ghostSpend = gs;
    });
  }

  Future<void> _add(double amount) async {
    if (current == null) return;
    final all = await Store.loadTx(current!.id);
    all.add(TxEntry(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      challengeId: current!.id,
      categoryId: 'c_other',
      amount: amount,
      note: 'GhostMode',
      tsMs: DateTime.now().millisecondsSinceEpoch,
    ));
    await Store.saveTx(current!.id, all);
    final sum = all.fold<double>(0.0, (s, v) => s + v.amount);
    final chs = await Store.loadChallenges();
    final idx = chs.indexWhere((e) => e.id == current!.id);
    if (idx >= 0) {
      chs[idx] = chs[idx].copyWith(spend: sum, tx: all.length);
      await Store.saveChallenges(chs);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (current == null || ghost == null) {
      return Scaffold(appBar: AppBar(title: const Text('Ghost Mode')), body: const Center(child: Text('Нет текущего челленджа.')));
    }
    final curSym = ProfileService.instance.currency;
    final double myScore = current!.planned <= 0
        ? 0.0
        : (((current!.planned - mySpend) / current!.planned).clamp(0.0, 1.0).toDouble()) * 100.0;

    final double ghostScore = ghost!.planned <= 0
        ? 0.0
        : (((ghost!.planned - ghostSpend) / ghost!.planned).clamp(0.0, 1.0).toDouble()) * 100.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Ghost Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Тема: ${current!.theme} · ${current!.days} д.'),
          const SizedBox(height: 12),
          _vsRow('Твои траты', mySpend, myScore),
          const SizedBox(height: 8),
          _vsRow('Призрак', ghostSpend, ghostScore, isGhost: true),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _add(150), child: Text('+ ${curSym}150'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _add(500), child: Text('+ ${curSym}500'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => _add(1000), child: Text('+ ${curSym}1000'))),
          ]),
          const Spacer(),
          Center(
            child: Text(
              myScore >= ghostScore ? 'Ты опережаешь призрака! 🎉' : 'Призрак впереди — есть куда расти 💪',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Завершить сравнение'),
          ),
        ]),
      ),
    );
  }

  Widget _vsRow(String title, double spend, double score, {bool isGhost = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(isGhost ? Icons.visibility : Icons.person, size: 20),
        const SizedBox(width: 6),
        Text(title),
        const Spacer(),
        Text('SS ${score.toStringAsFixed(1)}%'),
      ]),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: ((score / 100).clamp(0.0, 1.0)).toDouble()),
      const SizedBox(height: 4),
      Text('Траты: ${ProfileService.instance.currency}${spend.toStringAsFixed(0)}'),
    ]);
  }
}

/* =========================== WEEKLY SUMMARY =========================== */

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});
  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  Challenge? current;
  List<BudgetCategory> cats = [];
  List<TxEntry> txs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final challenges = await Store.loadChallenges();
    final currentId = await Store.getCurrentId();
    Challenge? c;
    if (currentId != null) {
      for (final e in challenges) {
        if (e.id == currentId) {
          c = e;
          break;
        }
      }
    }
    final categories = await Store.loadCategories();
    final t = c == null ? <TxEntry>[] : await Store.loadTx(c.id);
    if (mounted) setState(() {
      current = c;
      cats = categories;
      txs = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Scaffold(appBar: AppBar(title: const Text('Недельный отчёт')), body: const Center(child: Text('Нет текущего челленджа.')));
    }
    final cur = ProfileService.instance.currency;
    // Берём последние 7 дней
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final last7 = txs.where((t) => t.tsMs >= sevenDaysAgo).toList();

    // Сумма и топ-категория
    final total = last7.fold<double>(0.0, (s, t) => s + t.amount);
    final byCat = <String, double>{};
    for (final t in last7) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0.0) + t.amount;
    }
    String topCatName = '—';
    double topCatVal = 0.0;
    if (byCat.isNotEmpty) {
      final e = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topCatVal = e.first.value;
      final c = cats.firstWhere(
        (c) => c.id == e.first.key,
        orElse: () => BudgetCategory(id: e.first.key, name: 'Категория', icon: '📦'),
      );
      topCatName = '${c.icon} ${c.name}';
    }

    // День с макс. тратами
    final perDay = <String, double>{};
    for (final t in last7) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.tsMs);
      final key = '${d.year}-${d.month}-${d.day}';
      perDay[key] = (perDay[key] ?? 0.0) + t.amount;
    }
    double maxDay = 0.0;
    String maxDayStr = '—';
    perDay.forEach((k, v) {
      if (v > maxDay) {
        maxDay = v;
        maxDayStr = k;
      }
    });

    // Прогресс против плана
    final plan = current!.planned;
    final spend = current!.spend;
    final ss = current!.score;

    return Scaffold(
      appBar: AppBar(title: const Text('Недельный отчёт')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Суммарные траты за 7 дней'),
              subtitle: Text('$cur${total.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.leaderboard_outlined),
              title: const Text('Топ-категория недели'),
              subtitle: Text('$topCatName — $cur${topCatVal.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Максимум за день'),
              subtitle: Text('$maxDayStr — $cur${maxDay.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Прогресс челленджа'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ((ss / 100).clamp(0.0, 1.0)).toDouble()),
                const SizedBox(height: 6),
                Text('План: $cur${plan.toStringAsFixed(0)} · Траты: $cur${spend.toStringAsFixed(0)} · SS ${ss.toStringAsFixed(1)}%'),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================= AI TIPS ============================= */

class AITipsScreen extends StatelessWidget {
  const AITipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildTips(),
      builder: (context, snap) {
        final tips = snap.data as List<String>? ?? const [];
        return Scaffold(
          appBar: AppBar(title: const Text('AI Tips (локально)')),
          body: tips.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Недостаточно данных. Добавьте транзакции.')))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (_, i) => Card(child: ListTile(
                        leading: const Icon(Icons.tips_and_updates),
                        title: Text(tips[i]),
                      )),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: tips.length,
                ),
        );
      },
    );
  }

  Future<List<String>> _buildTips() async {
    final curId = await Store.getCurrentId();
    if (curId == null) return [];
    final ch = (await Store.loadChallenges()).firstWhere((e) => e.id == curId);
    final tx = await Store.loadTx(curId);
    if (tx.isEmpty) return [];
    final byCat = <String, double>{};
    for (final t in tx) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0.0) + t.amount;
    }
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    final overRatio = ch.planned > 0 ? (total / ch.planned) : 0.0;
    final tips = <String>[];

    // Совет 1: перераспределение 10%
    final alloc = await Store.loadAllocations(curId);
    if (alloc.isNotEmpty) {
      final sorted = (alloc.entries.toList()..sort((a, b) => (byCat[b.key] ?? 0).compareTo(byCat[a.key] ?? 0)));
      if (sorted.isNotEmpty) {
        final topKey = sorted.first.key;
        final _ = (alloc[topKey]! * 0.9).clamp(0.0, double.infinity).toDouble(); // расчёт как пример
        tips.add('Попробуй снизить лимит в «$topKey» на ~10% и перевести его в более приоритетные категории.');
      }
    }

    // Совет 2: предел дня
    final avgPerDay = ch.days > 0 ? (ch.planned / ch.days) : ch.planned;
    tips.add('Установи «дневной порог» ≈ ${avgPerDay.toStringAsFixed(0)} и придерживайся его.');

    // Совет 3: если >70%
    if (overRatio >= 0.7) {
      tips.add('Ты близок к 70% от плана — держи фокус на обязательных тратах и избегай импульсивных покупок.');
    } else {
      tips.add('Есть запас до 70% плана — часть сэкономленного отложи на цель или непредвиденные расходы.');
    }

    // Совет 4: топ-категория
    if (byCat.isNotEmpty) {
      final e = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topId = e.first.key;
      tips.add('Самая «тяжёлая» категория сейчас — $topId. Проверь подписки/повторы: можно ли сократить?');
    }

    return tips;
  }
}

/* =========================== FINANCE QUIZ ========================== */

class FinanceQuizScreen extends StatefulWidget {
  const FinanceQuizScreen({super.key});
  @override
  State<FinanceQuizScreen> createState() => _FinanceQuizScreenState();
}

class _FinanceQuizScreenState extends State<FinanceQuizScreen> {
  final qs = const [
    ('Сколько разумно держать в «подушке безопасности»?', ['1 месяц расходов', '3–6 месяцев расходов', '12 месяцев расходов'], 1),
    ('Что такое «эффект сложного процента»?', ['Процент только на первоначальную сумму', 'Процент на сумму + ранее начисленные проценты', 'Комиссия банка'], 1),
    ('Что делать сначала?', ['Инвестировать всё', 'Погасить дорогие долги', 'Взять новый кредит'], 1),
  ];
  int idx = 0;
  int correct = 0;
  bool answered = false;
  int? selected;

  void _answer(int i) {
    if (answered) return;
    setState(() {
      selected = i;
      answered = true;
      if (i == qs[idx].$3) correct++;
    });
  }

  Future<void> _next() async {
    if (idx < qs.length - 1) {
      setState(() {
        idx++;
        answered = false;
        selected = null;
      });
    } else {
      // награда
      await ProfileService.instance.addPoints(10 * correct);
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Готово!'),
                content: Text('Правильных: $correct из ${qs.length}. Начислено +${10 * correct} очков.'),
                actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Ок'))],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = qs[idx];
    return Scaffold(
      appBar: AppBar(title: const Text('ФинВикторина')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Вопрос ${idx + 1}/${qs.length}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(q.$1, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
          ...List.generate(q.$2.length, (i) {
            final isRight = i == q.$3;
            final selectedThis = selected == i;
            Color? color;
            if (answered) {
              if (selectedThis && isRight) {
                color = Colors.green.withOpacity(.2);
              } else if (selectedThis && !isRight) {
                color = Colors.red.withOpacity(.2);
              }
            }
            return Card(
              color: color,
              child: ListTile(
                title: Text(q.$2[i]),
                onTap: () => _answer(i),
                trailing: answered && selectedThis
                    ? Icon(isRight ? Icons.check_circle : Icons.cancel,
                        color: isRight ? Colors.green : Colors.red)
                    : null,
              ),
            );
          }),
          const Spacer(),
          FilledButton(
            onPressed: _next,
            child: Text(idx < qs.length - 1 ? 'Далее' : 'Завершить'),
          ),
        ]),
      ),
    );
  }
}

/* ============================ AVATAR STUDIO ========================= */

class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});
  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  String style = 'Классика';
  bool freeUsed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    freeUsed = p.getBool('avatar_free_used') ?? false;
    if (mounted) setState(() {});
  }

  Future<void> _gen() async {
    final prem = await PremiumService.isActive();
    if (freeUsed && !prem) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Нужен Премиум'),
          content: const Text('Бесплатная генерация уже использована. Включить пробный премиум на 3 дня?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Нет')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await PremiumService.startTrial3Days();
                setState(() {});
              },
              child: const Text('Активировать'),
            ),
          ],
        ),
      );
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setBool('avatar_free_used', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Аватар ($style) сгенерирован 🎨')),
    );
    setState(() => freeUsed = true);
  }

  @override
  Widget build(BuildContext context) {
    final nick = ProfileService.instance.nick;
    return Scaffold(
      appBar: AppBar(title: const Text('Аватар-студия')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Ник: $nick'),
            subtitle: const Text('Аватар на основе выбранного пола и ника'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.brush),
            title: const Text('Стиль'),
            subtitle: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Классика'),
                  selected: style == 'Классика',
                  onSelected: (_) => setState(() => style = 'Классика'),
                ),
                ChoiceChip(
                  label: const Text('Комикс'),
                  selected: style == 'Комикс',
                  onSelected: (_) => setState(() => style = 'Комикс'),
                ),
                ChoiceChip(
                  label: const Text('Пиксель-арт'),
                  selected: style == 'Пиксель-арт',
                  onSelected: (_) => setState(() => style = 'Пиксель-арт'),
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _gen,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Сгенерировать'),
          ),
        ]),
      ),
    );
  }
}

/* ============================ ACHIEVEMENTS ========================== */

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, bool> ach = const {};
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await AchievementsService.getAll();
    if (mounted) setState(() => ach = m);
  }

  Widget _tile(String key, String title, String subtitle, IconData icon) {
    final ok = ach[key] ?? false;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: ok ? Colors.green : null),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ok ? const Icon(Icons.verified, color: Colors.green) : const Icon(Icons.lock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ачивки')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tile(AchievementsService.kFirstStart, 'Первый шаг', 'Создай свой первый челлендж', Icons.flag),
            _tile(AchievementsService.kFirstFinish, 'Первый финиш', 'Заверши любой челлендж', Icons.emoji_events),
            _tile(AchievementsService.kThreeChallenges, 'Серия из трёх', 'Создай три челленджа', Icons.looks_3),
            _tile(AchievementsService.kSevenDay, 'Длинная дистанция', 'Выполни челлендж 7 дней', Icons.calendar_month),
            _tile(AchievementsService.kScore90, 'Мастер экономии', 'Достигни Savings Score ≥ 90%', Icons.star),
            const SizedBox(height: 8),
            const Text('Совет: ачивки легко расширить под маркетинговые события.'),
          ],
        ),
      ),
    );
  }
}

/* ============================ SETTINGS ============================== */

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _mode = ThemeController.instance.mode;
  bool _busy = false;

  final pinCtrl = TextEditingController();
  bool pinEnabled = false;

  final nickCtrl = TextEditingController();
  String currency = ProfileService.instance.currency;

  @override
  void initState() {
    super.initState();
    _loadPinState();
    nickCtrl.text = ProfileService.instance.nick;
  }

  Future<void> _loadPinState() async {
    pinEnabled = await LockService.isEnabled();
    if (mounted) setState(() {});
  }

  Future<void> _setMode(ThemeMode m) async {
    setState(() => _mode = m);
    await ThemeController.instance.set(m);
  }

  Future<void> _clearPremium() async {
    setState(() => _busy = true);
    await PremiumService.clear();
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Премиум сброшен')));
  }

  Future<void> _wipeChallenges() async {
    setState(() => _busy = true);
    await Store.wipeChallenges();
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Данные челленджей удалены')));
  }

  Future<void> _resetAchievements() async {
    setState(() => _busy = true);
    await AchievementsService.reset();
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ачивки сброшены')));
  }

  Future<void> _togglePin(bool v) async {
    await LockService.setEnabled(v);
    setState(() => pinEnabled = v);
  }

  Future<void> _savePin() async {
    final pin = pinCtrl.text.trim();
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN должен быть из 4 цифр')));
      return;
    }
    await LockService.setPin(pin);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN сохранён')));
  }

  Future<void> _saveProfile() async {
    final nick = nickCtrl.text.trim().isEmpty ? ProfileService.instance.nick : nickCtrl.text.trim();
    await ProfileService.instance.completeFirstRun(
      n: nick,
      g: ProfileService.instance.gender,
      cur: currency,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Тема'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('Светлая'), selected: _mode == ThemeMode.light, onSelected: (_) => _setMode(ThemeMode.light)),
              ChoiceChip(label: const Text('Тёмная'), selected: _mode == ThemeMode.dark, onSelected: (_) => _setMode(ThemeMode.dark)),
              ChoiceChip(label: const Text('Системная'), selected: _mode == ThemeMode.system, onSelected: (_) => _setMode(ThemeMode.system)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Профиль'),
          const SizedBox(height: 8),
          TextField(controller: nickCtrl, decoration: const InputDecoration(labelText: 'Ник', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('₽'), selected: currency == '₽', onSelected: (_) => setState(() => currency = '₽')),
            ChoiceChip(label: const Text('\$'), selected: currency == '\$', onSelected: (_) => setState(() => currency = '\$')),
            ChoiceChip(label: const Text('€'), selected: currency == '€', onSelected: (_) => setState(() => currency = '€')),
          ]),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: _saveProfile, child: const Text('Сохранить профиль')),
          const SizedBox(height: 24),
          const Text('Безопасность'),
          const SizedBox(height: 8),
          SwitchListTile(title: const Text('PIN при запуске'), value: pinEnabled, onChanged: _togglePin),
          Row(children: [
            Expanded(
              child: TextField(
                controller: pinCtrl,
                maxLength: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Новый PIN (4 цифры)',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _savePin, child: const Text('Сохранить')),
          ]),
          const SizedBox(height: 24),
          const Text('Данные'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: _busy ? null : _wipeChallenges, child: const Text('Очистить челленджи')),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: _busy ? null : _resetAchievements, child: const Text('Сбросить ачивки')),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: _busy ? null : _clearPremium, child: const Text('Сбросить премиум')),
        ],
      ),
    );
  }
}

/* ============================ REFERRAL ============================== */

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});
  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ctrl = TextEditingController();
  bool processing = false;

  Future<void> _apply() async {
    if (processing) return;
    setState(() => processing = true);
    final code = ctrl.text.trim();
    await Future.delayed(const Duration(milliseconds: 300));

    if (code.isEmpty) {
      setState(() => processing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите реферальный код')));
      }
      return;
    }

    await PremiumService.extendBy14Days();
    setState(() => processing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Подписка продлена на +14 дней')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реферал-код')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Введи код друга и получи +14 дней Премиума'),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Например: AIRI-2025',
              labelText: 'Код',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: processing ? null : _apply,
            icon: const Icon(Icons.check),
            label: Text(processing ? 'Применяем...' : 'Применить'),
          ),
        ]),
      ),
    );
  }
}

/* ============================ CHALLENGES ============================ */

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> list = [];
  String? currentId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = await Store.loadChallenges();
    final cid = await Store.getCurrentId();
    if (mounted) setState(() {
      list = l;
      currentId = cid;
    });
  }

  Future<void> _makeCurrent(String id) async {
    await Store.setCurrentId(id);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сделан текущим для дашборда')));
    }
  }

  Future<void> _delete(String id) async {
    final l = await Store.loadChallenges();
    l.removeWhere((e) => e.id == id);
    await Store.saveChallenges(l);
    final cid = await Store.getCurrentId();
    if (cid == id) await Store.setCurrentId(null);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои челленджи')),
      body: list.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Пока нет челленджей'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoloStartScreen())),
                child: const Text('Создать'),
              ),
            ]))
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = list[i];
                final isCurrent = e.id == currentId;
                return ListTile(
                  leading: CircleAvatar(child: Text(e.days.toString())),
                  title: Text(e.theme),
                  subtitle: Text(
                    'SS ${e.score.toStringAsFixed(1)}% · План ${ProfileService.instance.currency}${e.planned.toStringAsFixed(0)} · '
                    'Траты ${ProfileService.instance.currency}${e.spend.toStringAsFixed(0)}',
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (!isCurrent)
                      IconButton(
                        icon: const Icon(Icons.push_pin_outlined),
                        tooltip: 'Сделать текущим',
                        onPressed: () => _makeCurrent(e.id),
                      ),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(e.id)),
                  ]),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SoloProgressScreen(challengeId: e.id))),
                );
              },
            ),
    );
  }
}

/* =========================== LEADERBOARD (mock) ===================== */

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nick = ProfileService.instance.nick;
    final me = (nick.length > 10) ? '${nick.substring(0, 10)}…' : nick;
    final rows = [
      ('Airi', 96.3),
      ('Neo', 92.1),
      ('Sam', 90.4),
      (me, 88.7),
      ('Alex', 85.2),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Лидерборд')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(rows[i].$1),
            trailing: Text('SS ${rows[i].$2.toStringAsFixed(1)}%'),
          ),
        ),
      ),
    );
  }
}