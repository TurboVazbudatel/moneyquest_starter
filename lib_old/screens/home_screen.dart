
part of 'screens.dart';

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
