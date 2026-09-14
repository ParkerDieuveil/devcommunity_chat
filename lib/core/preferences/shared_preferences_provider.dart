import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instance bootstrapée dans [main] via `overrideWithValue`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'SharedPreferences non initialisé. '
    'Override [sharedPreferencesProvider] dans ProviderScope (voir main.dart).',
  );
});
