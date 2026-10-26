import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small things that are not secret: the last email and the theme.
/// Loaded before runApp, so the theme is right on the first frame.
class Settings extends ChangeNotifier {
  Settings(this._prefs);

  final SharedPreferences _prefs;

  static Future<Settings> load() async =>
      Settings(await SharedPreferences.getInstance());

  String get lastEmail => _prefs.getString('lastEmail') ?? '';

  // Enums are saved by name, never by index.
  ThemeMode get theme =>
      ThemeMode.values.byName(_prefs.getString('theme') ?? 'system');

  Future<void> saveLastEmail(String email) =>
      _prefs.setString('lastEmail', email);

  Future<void> saveTheme(ThemeMode mode) async {
    await _prefs.setString('theme', mode.name);
    notifyListeners(); // MaterialApp rebuilds with the new theme
  }
}
