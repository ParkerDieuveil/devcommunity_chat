import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/shared_preferences_provider.dart';

/// Préférence de thème persistée (device-local), source unique pour MaterialApp.
final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _storageKey = 'app_theme_mode';

  @override
  ThemeMode build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_storageKey);
    return _decode(raw) ?? ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(
          _storageKey,
          _encode(mode),
        );
  }

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  static ThemeMode? _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      };
}
