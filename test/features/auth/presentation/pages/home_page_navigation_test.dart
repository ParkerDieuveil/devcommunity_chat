import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';

import '../../../../helpers/test_prefs.dart';

void main() {
  group('HomePage - navigation par onglets', () {
    const user = AppUser(
      id: 'u1',
      email: 'user@example.com',
    );

    Future<void> pumpHomePage(WidgetTester tester) async {
      final prefs = await mockSharedPreferences();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith(
              (ref) => Stream.value(user),
            ),
            userChatsProvider(user.id).overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );
    }

    testWidgets('affiche l\'onglet Chats par défaut', (tester) async {
      await pumpHomePage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Chats'), findsWidgets);
      expect(find.text('Aucune discussion'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomePage)),
      );
      expect(container.read(mainTabProvider), MainTab.chat);
    });

    testWidgets('affiche les 4 destinations du menu', (tester) async {
      await pumpHomePage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Chats'), findsWidgets);
      expect(find.text('Groupes'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Plus'), findsOneWidget);
    });

    testWidgets('bascule vers Profil au tap', (tester) async {
      await pumpHomePage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsWidgets);
    });
  });
}
