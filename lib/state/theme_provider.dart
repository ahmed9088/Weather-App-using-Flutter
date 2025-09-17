import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool _isDark = false;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get theme => _themeData;
  bool get isDark => _isDark;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    _isDark = theme == ThemeData.dark();
    _saveTheme();
    notifyListeners();
  }

  void toggleTheme() {
    if (_isDark) {
      _themeData = ThemeData.light();
      _isDark = false;
    } else {
      _themeData = ThemeData.dark();
      _isDark = true;
    }
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('is_dark') ?? false;
    _themeData = _isDark ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}