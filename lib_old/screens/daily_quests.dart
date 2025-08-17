
part of 'screens.dart';

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
