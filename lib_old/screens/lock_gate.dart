
import 'package:flutter/material.dart';
import '../core/lock_service.dart';
import '../core/profile_service.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class LockGate extends StatefulWidget {
  const LockGate({super.key});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final enabled = await LockService.isEnabled();
    if (!enabled || LockService.isSessionUnlocked) {
      if (!mounted) return;
      if (!ProfileService.instance.firstRunDone) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: LockService.isEnabled(),
      builder: (ctx, snap) {
        final enabled = snap.data ?? false;
        if (!enabled || LockService.isSessionUnlocked) {
          return ProfileService.instance.firstRunDone ? const HomeScreen() : const OnboardingScreen();
        }
        return const PinLockScreen();
      },
    );
  }
}

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
