import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';

class SettingsViewModel extends AsyncNotifier<AppSettings> {
  static const _keyTheme = 'isDarkMode';
  static const _keyCurrency = 'currency';
  static const _keyNotifications = 'notificationsEnabled';

  @override
  FutureOr<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isDark = prefs.getBool(_keyTheme) ?? false;
    final currency = prefs.getString(_keyCurrency) ?? 'Bs.';
    final notifs = prefs.getBool(_keyNotifications) ?? true;

    return AppSettings(
      isDarkMode: isDark,
      currency: currency,
      notificationsEnabled: notifs,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
    state = AsyncData(state.value!.copyWith(isDarkMode: isDark));
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
    state = AsyncData(state.value!.copyWith(currency: currency));
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: enabled));
  }
}

final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, AppSettings>(() {
  return SettingsViewModel();
});
