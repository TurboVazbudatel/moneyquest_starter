
part of 'screens.dart';

class BudgetPlannerScreen extends StatelessWidget {
  const BudgetPlannerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BudgetPlannerScreen')),
      body: const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Этот экран будет вынесен из main.dart. TODO: перенести полную реализацию из исходного файла.'),
      )),
    );
  }
}
