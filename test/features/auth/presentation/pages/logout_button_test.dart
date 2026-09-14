import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/domain/usecases/logout_use_case.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';

import '../../fakes/fake_auth_repository.dart';

const _user = AppUser(id: 'u1', email: 'user@example.com');

Future<SharedPreferences> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  group('Bouton de déconnexion', () {
    testWidgets('depuis HomePage (onglet Profil), déclenche LogoutUseCase', (
      tester,
    ) async {
      final fakeRepository = FakeAuthRepository();
      addTearDown(fakeRepository.dispose);
      final prefs = await _prefs();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            logoutUseCaseProvider.overrideWithValue(
              LogoutUseCase(fakeRepository),
            ),
            userChatsProvider(_user.id).overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Profil'));
      await tester.pump();

      await tester.ensureVisible(find.text('Déconnexion'));
      await tester.tap(find.text('Déconnexion'));
      await tester.pump();
      await tester.pump();

      expect(fakeRepository.logoutCalled, isTrue);
    });

    testWidgets('depuis ProfilePage, déclenche LogoutUseCase', (tester) async {
      final fakeRepository = FakeAuthRepository();
      addTearDown(fakeRepository.dispose);
      final prefs = await _prefs();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            logoutUseCaseProvider.overrideWithValue(
              LogoutUseCase(fakeRepository),
            ),
          ],
          child: const MaterialApp(
            home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Déconnexion'));
      await tester.tap(find.text('Déconnexion'));
      await tester.pump();
      await tester.pump();

      expect(fakeRepository.logoutCalled, isTrue);
    });
  });
}
