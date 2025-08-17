import 'package:flutter/foundation.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._();
  ProfileService._();

  String? _username;
  String? get username => _username;

  Future<void> load() async {
    // Здесь может быть загрузка профиля из локального хранилища или API
    _username = "Adventurer";
    notifyListeners();
  }

  void updateName(String name) {
    _username = name;
    notifyListeners();
  }
}
