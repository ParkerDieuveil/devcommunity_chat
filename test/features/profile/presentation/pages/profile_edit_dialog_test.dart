import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../fakes/fake_profile_repository.dart';

const _user = AppUser(
  id: 'user-123',
  email: 'alex@example.com',
  displayName: 'Alexandre',
);

Future<void> _pumpProfilePage(
  WidgetTester tester, {
  required FakeProfileRepository repository,
}) async {
  SharedPreferences.setMockInitialValues(const {});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => Stream.value(_user)),
        profileRepositoryProvider.overrideWithValue(repository),
        profileSalonCountProvider.overrideWith((ref) => const AsyncData(0)),
      ],
      child: const MaterialApp(
        home: ProfilePage(
          avatarImage: AssetImage('assets/images/dev.png'),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Modifier mon profil'));
  await tester.tap(find.text('Modifier mon profil'));
  await tester.pumpAndSettle();
}

void main() {
  group('ProfilePage - modification du profil (cas limites)', () {
    testWidgets(
      'un échec d\'enregistrement affiche une erreur et garde la boîte de dialogue ouverte',
      (tester) async {
        final repository = FakeProfileRepository(
          profile: ProfileEntity(
            id: 'user-123',
            displayname: 'Alexandre',
            email: 'alex@example.com',
            bio: 'Bio',
            photoUrl: '',
          ),
        )..updateProfileError = Exception('Firestore indisponible');

        await _pumpProfilePage(tester, repository: repository);

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.text('Enregistrer'), findsOneWidget);
        expect(
          find.textContaining('Échec de la mise à jour'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'annuler ferme la boîte de dialogue sans appeler UpdateProfile',
      (tester) async {
        final repository = FakeProfileRepository(
          profile: ProfileEntity(
            id: 'user-123',
            displayname: 'Alexandre',
            email: 'alex@example.com',
            bio: 'Bio',
            photoUrl: '',
          ),
        );

        await _pumpProfilePage(tester, repository: repository);

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('Enregistrer'), findsNothing);
        expect(repository.updateProfileCallCount, 0);
      },
    );

    testWidgets(
      'un nom vide est refusé sans appeler UpdateProfile',
      (tester) async {
        final repository = FakeProfileRepository(
          profile: ProfileEntity(
            id: 'user-123',
            displayname: 'Alexandre',
            email: 'alex@example.com',
            bio: 'Bio',
            photoUrl: '',
          ),
        );

        await _pumpProfilePage(tester, repository: repository);

        await tester.enterText(
          find.byType(TextField).at(0),
          '',
        );

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.text('Le nom est obligatoire.'), findsOneWidget);
        expect(repository.updateProfileCallCount, 0);
      },
    );
  });
}