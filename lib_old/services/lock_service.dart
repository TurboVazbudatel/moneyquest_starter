import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const _kPin = 'app_pin';
  static const _kPinEnabled = 'pin_enabled';
  static bool _sessionUnlocked = false;

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kPinEnabled) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPinEnabled, v);
    if (!v) _sessionUnlocked = true;
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPin, pin);
  }

  static Future<bool> verify(String pin) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getString(_kPin);
    final ok = (cur != null && cur == pin);
    if (ok) _sessionUnlocked = true;
    return ok;
  }

  static bool get isSessionUnlocked => _sessionUnlocked;
}
