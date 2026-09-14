import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/domain/usecases/logout_use_case.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';

import '../../fakes/fake_auth_repository.dart';

const _user = AppUser(id: 'u1', email: 'user@example.com');

void main() {
  group('Bouton de déconnexion', () {
    testWidgets('depuis HomePage, déclenche LogoutUseCase', (tester) async {
      final fakeRepository = FakeAuthRepository();
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            logoutUseCaseProvider.overrideWithValue(
              LogoutUseCase(fakeRepository),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.logout));
      await tester.pump();
      await tester.pump();

      expect(fakeRepository.logoutCalled, isTrue);
    });

    testWidgets('depuis ProfilePage, déclenche LogoutUseCase', (tester) async {
      final fakeRepository = FakeAuthRepository();
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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
