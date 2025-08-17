import 'package:flutter/material.dart';
import '../../services/lock_service.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../services/profile_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});
  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final ctrl = TextEditingController();
  String err = '';
  Future<void> _submit() async {
    final ok = await LockService.verify(ctrl.text);
    if (ok && mounted) {
      if (!ProfileService.instance.firstRunDone) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } else {
      setState(() => err = 'Неверный PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Введите PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Для входа в приложение введите 4-значный PIN'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLength: 4,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••'),
            ),
            if (err.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(err, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Войти')),
          ],
        ),
      ),
    );
  }
}
