import 'package:shared_preferences/shared_preferences.dart';

/// Prefs mockés pour les widget tests (locale / thème / onboarding).
Future<SharedPreferences> mockSharedPreferences([
  Map<String, Object>? values,
]) async {
  SharedPreferences.setMockInitialValues({
    'app_locale': 'fr',
    'onboarding_done': true,
    ...?values,
  });
  return SharedPreferences.getInstance();
}
