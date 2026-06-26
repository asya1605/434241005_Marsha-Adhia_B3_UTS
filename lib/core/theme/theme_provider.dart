import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static bool isDark = false;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkVal = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDarkVal ? ThemeMode.dark : ThemeMode.light;
      isDark = isDarkVal;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading theme preference: $e");
    }
  }

  Future<void> toggleTheme(bool isDarkVal) async {
    _themeMode = isDarkVal ? ThemeMode.dark : ThemeMode.light;
    isDark = isDarkVal;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', isDarkVal);
    } catch (e) {
      debugPrint("Error saving theme preference: $e");
    }
  }
}