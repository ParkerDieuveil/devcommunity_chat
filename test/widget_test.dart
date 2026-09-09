import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:devcommunitychat/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets(
    'LoginPage affiche correctement le formulaire de connexion',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      expect(find.text('DevCommunity Chat'), findsOneWidget);
      expect(find.text('Connectez-vous à votre communauté.'), findsOneWidget);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);

      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);
    },
  );
}