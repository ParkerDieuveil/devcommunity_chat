import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/presentation/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    Future<void> pumpLoginPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );
    }

    testWidgets('affiche les éléments principaux', (tester) async {
      await pumpLoginPage(tester);

      expect(find.text('DevCommunity Chat'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('valide un email vide', (tester) async {
      await pumpLoginPage(tester);

      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      expect(
        find.text('Veuillez entrer votre email.'),
        findsOneWidget,
      );
    });

    testWidgets('valide un email incorrect', (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'email-invalide',
      );

      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      expect(
        find.text('Veuillez entrer une adresse email valide.'),
        findsOneWidget,
      );
    });

    testWidgets('valide un mot de passe vide', (tester) async {
      await pumpLoginPage(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );

      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      expect(
        find.text('Veuillez entrer votre mot de passe.'),
        findsOneWidget,
      );
    });
  });
}