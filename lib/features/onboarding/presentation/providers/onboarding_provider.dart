import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/preferences/shared_preferences_provider.dart';

const _onboardingDoneKey = 'onboarding_done';

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
  OnboardingCompletedNotifier.new,
);

class OnboardingCompletedNotifier extends Notifier<bool> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() {
    return _prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> complete() async {
    await _prefs.setBool(_onboardingDoneKey, true);
    state = true;
  }

  Future<void> reset() async {
    await _prefs.setBool(_onboardingDoneKey, false);
    state = false;
  }
}
