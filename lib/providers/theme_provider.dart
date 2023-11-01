import 'package:flutter/material.dart';

import '../helpers/globals.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = "current-theme";

  ThemeProvider() {
    int? themeIndex = sharedPreferences.getInt(_prefKey);
    if (themeIndex == null) {
      _themeMode = ThemeMode.system;
      return;
    }
    _themeMode = ThemeMode.values.elementAt(themeIndex);
  }

  late ThemeMode _themeMode;

  ThemeMode get mode => _themeMode;

  void toggleTheme() {
    debugPrint("ThemeProvider.toggleTheme: ");
    int currentThemeModeIndex = ThemeMode.values.indexWhere(
      (element) => element == _themeMode,
    );

    int nextThemeIndex = (currentThemeModeIndex + 1) % ThemeMode.values.length;
    _themeMode = ThemeMode.values.elementAt(nextThemeIndex);
    sharedPreferences.setInt(_prefKey, nextThemeIndex);
    notifyListeners();
  }

  IconData get icon {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.settings_suggest_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      default:
        return Icons.light_mode_outlined;
    }
  }
}
