
part of 'screens.dart';

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
              min: 300.0,
              max: 10000.0,
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
