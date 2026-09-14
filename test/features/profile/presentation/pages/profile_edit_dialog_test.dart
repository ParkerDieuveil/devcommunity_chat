import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/domain/usecases/update_profile.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../fakes/fake_profile_repository.dart';

const _user = AppUser(
  id: 'user-123',
  email: 'alex@example.com',
  displayName: 'Alexandre',
);

void main() {
  group('ProfilePage - modification du profil', () {
    late FakeProfileRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeProfileRepository();
    });

    Future<void> pumpProfilePage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            updateProfileProvider.overrideWithValue(
              UpdateProfile(fakeRepository),
            ),
          ],
          child: const MaterialApp(
            home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Modifier mon profil'));
      await tester.tap(find.text('Modifier mon profil'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'enregistrer appelle UpdateProfile avec les nouvelles valeurs, ferme la boîte de dialogue et confirme',
      (tester) async {
        await pumpProfilePage(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Nom'),
          'Alexandre Dupont',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Bio'),
          'Développeur Flutter',
        );

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(fakeRepository.updateCalls, hasLength(1));
        final call = fakeRepository.updateCalls.single;
        expect(call.userId, 'user-123');
        expect(call.name, 'Alexandre Dupont');
        expect(call.email, 'alex@example.com');
        expect(call.bio, 'Développeur Flutter');

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Profil mis à jour.'), findsOneWidget);
      },
    );

    testWidgets(
      'un échec d\'enregistrement affiche un message d\'erreur et garde la boîte de dialogue ouverte',
      (tester) async {
        fakeRepository.updateProfileError = Exception('Firestore indisponible');

        await pumpProfilePage(tester);

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.textContaining('Échec de la mise à jour'), findsOneWidget);
      },
    );

    testWidgets('annuler ferme la boîte de dialogue sans appeler UpdateProfile', (
      tester,
    ) async {
      await pumpProfilePage(tester);

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(fakeRepository.updateCalls, isEmpty);
    });
  });
}
