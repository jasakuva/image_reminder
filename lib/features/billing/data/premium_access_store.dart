import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumAccessStore extends ChangeNotifier {
  static const freeActiveReminderLimit = 2;
  static const _premiumKey = 'is_premium_user';

  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _isPremium = preferences.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_premiumKey, value);
    notifyListeners();
  }
}