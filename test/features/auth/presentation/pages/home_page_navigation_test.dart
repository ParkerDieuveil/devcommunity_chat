import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('HomePage - navigation par onglets', () {
    const user = AppUser(id: 'u1', email: 'user@example.com');

    Future<void> pumpHomePage(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      );
    }

    testWidgets('affiche l\'onglet Home par défaut', (tester) async {
      await pumpHomePage(tester);
      await tester.pump();

      expect(find.text('Ouvrir le chat'), findsOneWidget);
    });

    testWidgets('chaque destination a une icône cohérente avec son label', (
      tester,
    ) async {
      await pumpHomePage(tester);
      await tester.pump();

      final destinations = tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .toList();

      final byLabel = {for (final d in destinations) d.label: d};

      expect((byLabel['Home']!.icon as Icon).icon, Icons.home_outlined);
      expect((byLabel['Chat']!.icon as Icon).icon, Icons.chat_outlined);
      expect((byLabel['Profil']!.icon as Icon).icon, Icons.person_outline);
    });

    testWidgets('bascule vers l\'onglet Chat au tap', (tester) async {
      await pumpHomePage(tester);
      await tester.pump();

      await tester.tap(find.text('Chat'));
      await tester.pump();

      expect(find.text('DevCommunity Chat'), findsWidgets);
      expect(find.text('0 message(s)'), findsOneWidget);
    });

    testWidgets('bascule vers l\'onglet Profil au tap', (tester) async {
      await pumpHomePage(tester);
      await tester.pump();

      await tester.tap(find.text('Profil'));
      await tester.pump();

      expect(find.text('Mon Profil'), findsOneWidget);
      expect(find.text('Déconnexion'), findsOneWidget);
    });
  });
}
