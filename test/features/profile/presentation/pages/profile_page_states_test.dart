import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';
import 'package:devcommunitychat/features/profile/presentation/widgets/profile_theme_option.dart';

import '../../fakes/fake_profile_repository.dart';

const _user = AppUser(
  id: 'user-123',
  email: 'alex@example.com',
  displayName: 'Alexandre',
);

Future<void> _pumpProfilePage(
  WidgetTester tester,
  Stream<AppUser?> authStream,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [authStateProvider.overrideWith((ref) => authStream)],
      child: const MaterialApp(
        home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
      ),
    ),
  );
}

void main() {
  group('ProfilePage - états', () {
    testWidgets(
      'affiche un loader tant que la session est en cours de chargement',
      (tester) async {
        await _pumpProfilePage(tester, const Stream.empty());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('affiche un message si aucun utilisateur n\'est connecté', (
      tester,
    ) async {
      await _pumpProfilePage(tester, Stream.value(null));
      await tester.pump();

      expect(find.text('Aucun utilisateur connecté'), findsOneWidget);
    });

    testWidgets(
      'affiche un message d\'erreur si le flux authStateProvider échoue',
      (tester) async {
        await _pumpProfilePage(tester, Stream<AppUser?>.error('Erreur réseau'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Erreur'), findsOneWidget);
      },
    );
  });

  group('ProfilePage - interactions', () {
    testWidgets('changer de thème met à jour la sélection visuelle', (
      tester,
    ) async {
      await _pumpProfilePage(tester, Stream.value(_user));
      await tester.pump();

      ProfileThemeOption optionFor(String title) =>
          tester.widget(find.widgetWithText(ProfileThemeOption, title));

      expect(optionFor('Sombre').isSelected, isTrue);

      expect(optionFor('Clair').isSelected, isFalse);

      await tester.ensureVisible(find.text('Clair'));

      await tester.tap(find.text('Clair'));

      await tester.pump();

      expect(optionFor('Clair').isSelected, isTrue);

      expect(optionFor('Sombre').isSelected, isFalse);
    });

    testWidgets('ouvre la boîte de dialogue d\'édition pré-remplie', (
      tester,
    ) async {
      await _pumpProfilePage(tester, Stream.value(_user));
      await tester.pump();

      await tester.ensureVisible(find.text('Modifier mon profil'));

      await tester.tap(find.text('Modifier mon profil'));

      await tester.pumpAndSettle();

      expect(find.text('Modifier mon profil'), findsWidgets);

      final textFields = find.byType(TextField);

      expect(textFields, findsNWidgets(3));

      expect(
        tester.widget<TextField>(textFields.at(0)).controller?.text,
        'Alexandre',
      );

      expect(
        tester.widget<TextField>(textFields.at(1)).controller?.text,
        'alex@example.com',
      );

      await tester.tap(find.text('Annuler'));

      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('ProfilePage - mise à jour du profil', () {
    testWidgets('enregistre les modifications du profil via UpdateProfile', (
      tester,
    ) async {
      final fakeRepository = FakeProfileRepository(
        profile: ProfileEntity(
          id: 'user-123',
          displayname: 'Alexandre',
          email: 'alex@example.com',
          bio: 'Ancienne bio',
          photoUrl: '',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            profileRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
          ),
        ),
      );

      await tester.pump();

      // Ouvrir la boîte de dialogue.
      await tester.ensureVisible(find.text('Modifier mon profil'));

      await tester.tap(find.text('Modifier mon profil'));

      await tester.pumpAndSettle();

      // Le dialogue contient exactement 3 champs :
      // 0 = Nom
      // 1 = Email
      // 2 = Bio
      final textFields = find.byType(TextField);

      expect(textFields, findsNWidgets(3));

      // Modifier le nom.
      await tester.enterText(textFields.at(0), 'Jean Dupont');

      // Modifier l'email.
      await tester.enterText(textFields.at(1), 'jean@example.com');

      // Modifier la bio.
      await tester.enterText(textFields.at(2), 'Développeur Flutter passionné');

      // Enregistrer.
      await tester.tap(find.text('Enregistrer'));

      await tester.pumpAndSettle();

      // Vérifie que updateProfile a bien été appelé.
      expect(fakeRepository.updateProfileCallCount, 1);

      // Vérifie l'utilisateur ciblé.
      expect(fakeRepository.lastUserId, 'user-123');

      // Vérifie les données envoyées.
      expect(fakeRepository.lastName, 'Jean Dupont');

      expect(fakeRepository.lastEmail, 'jean@example.com');

      expect(fakeRepository.lastBio, 'Développeur Flutter passionné');

      // Vérifie que le profil a été mis à jour.
      expect(fakeRepository.profile?.displayname, 'Jean Dupont');

      expect(fakeRepository.profile?.email, 'jean@example.com');

      expect(fakeRepository.profile?.bio, 'Développeur Flutter passionné');

      // Vérifie que la boîte de dialogue est fermée.
      expect(find.byType(AlertDialog), findsNothing);

      // Vérifie le message de confirmation.
      expect(find.text('Profil mis à jour.'), findsOneWidget);
    });
  });
}
