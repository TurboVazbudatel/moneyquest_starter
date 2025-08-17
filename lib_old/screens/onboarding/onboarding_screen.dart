import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../home/home_screen.dart';

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
