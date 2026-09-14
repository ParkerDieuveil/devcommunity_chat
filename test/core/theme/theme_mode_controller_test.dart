import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/theme/theme_mode_controller.dart';

void main() {
  test('ThemeModeController persiste et restaure le mode', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(prefs.getString('app_theme_mode'), 'light');

    final restored = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(restored.dispose);
    expect(restored.read(themeModeProvider), ThemeMode.light);
  });
}
