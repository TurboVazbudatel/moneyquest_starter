
part of 'screens.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AchievementsScreen')),
      body: const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Этот экран будет вынесен из main.dart. TODO: перенести полную реализацию из исходного файла.'),
      )),
    );
  }
}
