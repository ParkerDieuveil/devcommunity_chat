import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/shared_preferences_provider.dart';

/// Préférence de langue persistée (device-local), source unique pour MaterialApp.
final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  static const _storageKey = 'app_locale';

  static const supported = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  @override
  Locale build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_storageKey);
    return _decode(raw) ?? const Locale('fr');
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = Locale(locale.languageCode);
    if (!supported.any((l) => l.languageCode == normalized.languageCode)) {
      return;
    }
    if (state.languageCode == normalized.languageCode) return;
    state = normalized;
    await ref.read(sharedPreferencesProvider).setString(
          _storageKey,
          normalized.languageCode,
        );
  }

  static Locale? _decode(String? raw) => switch (raw) {
        'fr' => const Locale('fr'),
        'en' => const Locale('en'),
        _ => null,
      };
}
