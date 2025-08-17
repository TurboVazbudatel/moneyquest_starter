
part of 'screens.dart';

class SoloProgressScreen extends StatefulWidget {
  final String challengeId;
  const SoloProgressScreen({super.key, required this.challengeId});
  @override
  State<SoloProgressScreen> createState() => _SoloProgressScreenState();
}

class _SoloProgressScreenState extends State<SoloProgressScreen> {
  static const String curSym = '₽'; 
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
