import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MoneyQuest Home')),
      body: const Center(
        child: Text(
          '🏠 Dashboard',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
