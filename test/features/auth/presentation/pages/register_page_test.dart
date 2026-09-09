import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/presentation/pages/register_page.dart';

void main() {
  group('RegisterPage', () {
    Future<void> pumpRegisterPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );
    }

    testWidgets('affiche les éléments principaux', (tester) async {
      await pumpRegisterPage(tester);

      expect(find.text('Rejoignez DevCommunity'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe'), findsOneWidget);
      expect(find.text('Créer mon compte'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('valide un email vide', (tester) async {
      await pumpRegisterPage(tester);

      await tester.tap(find.text('Créer mon compte'));
      await tester.pump();

      expect(
        find.text('Veuillez entrer votre email.'),
        findsOneWidget,
      );
    });

    testWidgets('valide un mot de passe trop court', (tester) async {
      await pumpRegisterPage(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(
        fields.at(0),
        'test@example.com',
      );

      await tester.enterText(
        fields.at(1),
        '123',
      );

      await tester.tap(find.text('Créer mon compte'));
      await tester.pump();

      expect(
        find.text('Minimum 6 caractères.'),
        findsOneWidget,
      );
    });

    testWidgets('valide la confirmation du mot de passe', (tester) async {
      await pumpRegisterPage(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(
        fields.at(0),
        'test@example.com',
      );

      await tester.enterText(
        fields.at(1),
        'password123',
      );

      await tester.enterText(
        fields.at(2),
        'different123',
      );

      await tester.tap(find.text('Créer mon compte'));
      await tester.pump();

      expect(
        find.text('Les mots de passe ne correspondent pas.'),
        findsOneWidget,
      );
    });
  });
}