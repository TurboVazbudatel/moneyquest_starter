
part of 'screens.dart';

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
