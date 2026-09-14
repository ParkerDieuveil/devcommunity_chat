import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:devcommunitychat/features/profile/presentation/widgets/profile_theme_option.dart';

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
    testWidgets('affiche un loader tant que la session est en cours de chargement', (
      tester,
    ) async {
      await _pumpProfilePage(tester, const Stream.empty());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('affiche un message si aucun utilisateur n\'est connecté', (
      tester,
    ) async {
      await _pumpProfilePage(tester, Stream.value(null));
      await tester.pump();

      expect(find.text('Aucun utilisateur connecté'), findsOneWidget);
    });

    testWidgets('affiche un message d\'erreur si le flux authStateProvider échoue', (
      tester,
    ) async {
      await _pumpProfilePage(
        tester,
        Stream<AppUser?>.error('Erreur réseau'),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur'), findsOneWidget);
    });
  });

  group('ProfilePage - interactions', () {
    testWidgets('changer de thème met à jour la sélection visuelle', (
      tester,
    ) async {
      await _pumpProfilePage(tester, Stream.value(_user));
      await tester.pump();

      ProfileThemeOption optionFor(String title) => tester.widget(
        find.widgetWithText(ProfileThemeOption, title),
      );

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
      expect(find.widgetWithText(TextField, 'Nom'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == 'Alexandre',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == 'alex@example.com',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
