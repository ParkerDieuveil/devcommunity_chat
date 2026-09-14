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
    final decoded = _decode(raw) ?? ThemeMode.dark;
    // Ancien choix « Système » : on le fige selon l’appareil (souvent clair
    // sur émulateur — d’où l’impression de bug).
    if (decoded == ThemeMode.system) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return decoded;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final resolved = mode == ThemeMode.system
        ? (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light)
        : mode;
    if (state == resolved) return;
    state = resolved;
    await ref.read(sharedPreferencesProvider).setString(
          _storageKey,
          _encode(resolved),
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
