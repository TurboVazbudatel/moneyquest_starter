import 'package:flutter/material.dart';
import '../../app/app_router.dart';

class LockGate extends StatelessWidget {
  const LockGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔒 Welcome to MoneyQuest',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRouter.home);
              },
              child: const Text("Войти"),
            ),
          ],
        ),
      ),
    );
  }
}