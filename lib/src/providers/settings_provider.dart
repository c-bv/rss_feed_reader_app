import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption {
  system,
  light,
  dark;

  String get displayTitle {
    switch (this) {
      case ThemeOption.system:
        return 'System';
      case ThemeOption.light:
        return 'Light';
      case ThemeOption.dark:
        return 'Dark';
      default:
        return '';
    }
  }
}

enum SyncFrequency {
  manual(0),
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60),
  threeHours(180),
  sixHours(360),
  twelveHours(720),
  twentyFourHours(1440);

  final int minutes;

  const SyncFrequency(this.minutes);

  String get displayTitle {
    switch (this) {
      case SyncFrequency.manual:
        return 'Manual';
      case SyncFrequency.fifteenMinutes:
        return 'Every 15 minutes';
      case SyncFrequency.thirtyMinutes:
        return 'Every 30 minutes';
      case SyncFrequency.oneHour:
        return 'Every hour';
      case SyncFrequency.threeHours:
        return 'Every 3 hours';
      case SyncFrequency.sixHours:
        return 'Every 6 hours';
      case SyncFrequency.twelveHours:
        return 'Every 12 hours';
      case SyncFrequency.twentyFourHours:
        return 'Every day';
      default:
        return '';
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  ThemeOption _themeOption = ThemeOption.system;
  bool _showUnreadCount = true;
  bool _syncOnAppStart = true;
  SyncFrequency _syncFrequency = SyncFrequency.oneHour;

  ThemeOption get themeOption => _themeOption;
  bool get showUnreadCount => _showUnreadCount;
  bool get syncOnAppStart => _syncOnAppStart;
  SyncFrequency get syncFrequency => _syncFrequency;

  SettingsProvider() {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int themeIndex = prefs.getInt('themeOption') ?? ThemeOption.system.index;
    _themeOption = ThemeOption.values[themeIndex];

    _showUnreadCount = prefs.getBool('showUnreadCount') ?? true;
    _syncOnAppStart = prefs.getBool('syncOnAppStart') ?? true;

    notifyListeners();
  }

  void setThemeOption(ThemeOption option) async {
    _themeOption = option;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeOption', _themeOption.index);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    switch (_themeOption) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
      default:
        return ThemeMode.system;
    }
  }

  void setShowUnreadCount(bool value) async {
    _showUnreadCount = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showUnreadCount', value);
    notifyListeners();
  }

  void setSyncOnAppStart(bool value) async {
    _syncOnAppStart = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncOnAppStart', value);
    notifyListeners();
  }

  void setSyncFrequency(int value) async {
    _syncFrequency = SyncFrequency.values[value];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('syncFrequency', value);
    notifyListeners();
  }
}
