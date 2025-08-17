
part of 'screens.dart';

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
