import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleSettingsStore extends ChangeNotifier {
  static const _localeKey = 'app_locale_code';

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_localeKey);
    if (code == null || code.isEmpty) {
      _locale = null;
      return;
    }

    _locale = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final preferences = await SharedPreferences.getInstance();
    if (locale == null) {
      await preferences.remove(_localeKey);
    } else {
      await preferences.setString(_localeKey, locale.languageCode);
    }
    notifyListeners();
  }
}