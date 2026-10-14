import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/bobo_theme.dart';

class AppTheme extends ChangeNotifier {
  static const _prefsKey = 'theme_accent';

  BoboAccent _accent = BoboAccent.bobobidou;
  ThemeData _currentTheme = BoboTheme.build(BoboAccent.bobobidou);

  AppTheme() {
    _restore();
  }

  BoboAccent get accent => _accent;
  ThemeData get currentTheme => _currentTheme;

  Future<void> setAccent(BoboAccent accent) async {
    if (accent == _accent) return;
    _apply(accent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, accent.name);
  }

  void _apply(BoboAccent accent) {
    _accent = accent;
    _currentTheme = BoboTheme.build(accent);
    notifyListeners();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    final accent = BoboAccent.values.where((a) => a.name == saved);
    if (accent.isNotEmpty) _apply(accent.first);
  }
}
