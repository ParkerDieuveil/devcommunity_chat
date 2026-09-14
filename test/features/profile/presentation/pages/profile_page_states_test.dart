import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/theme/theme_mode_controller.dart';
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

Future<SharedPreferences> _prefs({String? themeMode}) async {
  SharedPreferences.setMockInitialValues({
    'app_theme_mode': ?themeMode,
  });
  return SharedPreferences.getInstance();
}

Future<void> _pumpProfilePage(
  WidgetTester tester, {
  required Stream<AppUser?> authStream,
  FakeProfileRepository? repository,
  String? themeMode,
}) async {
  final prefs = await _prefs(themeMode: themeMode);
  final fake = repository ??
      FakeProfileRepository(
        profile: ProfileEntity(
          id: 'user-123',
          displayname: 'Alexandre',
          email: 'alex@example.com',
          bio: 'Bio de test',
          photoUrl: '',
          title: 'Flutter Dev',
          createdAt: DateTime(2024, 3, 1),
          isOnline: true,
        ),
      );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => authStream),
        profileRepositoryProvider.overrideWithValue(fake),
        profileSalonCountProvider.overrideWith((ref) => const AsyncData(3)),
      ],
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
        await _pumpProfilePage(tester, authStream: const Stream.empty());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('affiche un message si aucun utilisateur n\'est connecté', (
      tester,
    ) async {
      await _pumpProfilePage(tester, authStream: Stream.value(null));
      await tester.pump();

      expect(find.text('Aucun utilisateur connecté'), findsOneWidget);
    });

    testWidgets(
      'affiche un message d\'erreur si le flux authStateProvider échoue',
      (tester) async {
        await _pumpProfilePage(
          tester,
          authStream: Stream<AppUser?>.error('Erreur réseau'),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Erreur'), findsOneWidget);
      },
    );
  });

  group('ProfilePage - données réelles', () {
    testWidgets('affiche bio, titre et stats issus du profil / chats', (
      tester,
    ) async {
      await _pumpProfilePage(tester, authStream: Stream.value(_user));
      await tester.pumpAndSettle();

      expect(find.text('Alexandre'), findsOneWidget);
      expect(find.text('Bio de test'), findsOneWidget);
      expect(find.textContaining('Flutter Dev'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Salons'), findsOneWidget);
      expect(find.text('En ligne'), findsOneWidget);
      expect(find.textContaining('mars 2024'), findsOneWidget);
    });
  });

  group('ProfilePage - interactions', () {
    testWidgets('changer de thème met à jour la sélection et le provider', (
      tester,
    ) async {
      await _pumpProfilePage(
        tester,
        authStream: Stream.value(_user),
        themeMode: 'dark',
      );
      await tester.pumpAndSettle();

      ProfileThemeOption optionFor(String title) =>
          tester.widget(find.widgetWithText(ProfileThemeOption, title));

      expect(optionFor('Sombre').isSelected, isTrue);
      expect(optionFor('Clair').isSelected, isFalse);

      await tester.ensureVisible(find.text('Clair'));
      await tester.tap(find.text('Clair'));
      await tester.pumpAndSettle();

      expect(optionFor('Clair').isSelected, isTrue);
      expect(optionFor('Sombre').isSelected, isFalse);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfilePage)),
      );
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('ouvre la boîte de dialogue d\'édition pré-remplie', (
      tester,
    ) async {
      await _pumpProfilePage(tester, authStream: Stream.value(_user));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Modifier mon profil'));
      await tester.tap(find.text('Modifier mon profil'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));
      expect(
        tester.widget<TextField>(textFields.at(0)).controller?.text,
        'Alexandre',
      );
      expect(
        tester.widget<TextField>(textFields.at(1)).controller?.text,
        'Flutter Dev',
      );
      expect(
        tester.widget<TextField>(textFields.at(2)).controller?.text,
        'Bio de test',
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
          title: 'Ancien titre',
        ),
      );

      await _pumpProfilePage(
        tester,
        authStream: Stream.value(_user),
        repository: fakeRepository,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Modifier mon profil'));
      await tester.tap(find.text('Modifier mon profil'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), 'Jean Dupont');
      await tester.enterText(textFields.at(1), 'Staff Engineer');
      await tester.enterText(textFields.at(2), 'Développeur Flutter passionné');

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(fakeRepository.updateProfileCallCount, 1);
      expect(fakeRepository.lastUserId, 'user-123');
      expect(fakeRepository.lastName, 'Jean Dupont');
      expect(fakeRepository.lastTitle, 'Staff Engineer');
      expect(fakeRepository.lastBio, 'Développeur Flutter passionné');
      expect(fakeRepository.profile?.displayname, 'Jean Dupont');
      expect(fakeRepository.profile?.title, 'Staff Engineer');
      expect(fakeRepository.profile?.bio, 'Développeur Flutter passionné');
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Profil mis à jour.'), findsOneWidget);
    });
  });
}
