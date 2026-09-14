import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';

void main() {
  group('HomePage - navigation par onglets', () {
    const user = AppUser(
      id: 'u1',
      email: 'user@example.com',
    );

    Future<void> pumpHomePage(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

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
      await tester.pump();

      expect(find.text('Chats'), findsWidgets);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('bascule vers Profile au tap', (tester) async {
      await pumpHomePage(tester);
      await tester.pump();

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(find.text('Déconnexion'), findsOneWidget);
    });
  });
}
