import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../../../helpers/test_prefs.dart';
import '../../../profile/fakes/fake_profile_repository.dart';

void main() {
  group('HomePage - navigation par onglets', () {
    const user = AppUser(
      id: 'u1',
      email: 'user@example.com',
      displayName: 'Alexandre',
    );

    Future<void> pumpHomePage(WidgetTester tester) async {
      final prefs = await mockSharedPreferences();

      final fakeProfileRepository = FakeProfileRepository(
        profile: ProfileEntity(
          id: user.id,
          displayname: 'Alexandre',
          email: user.email,
          bio: 'Bio de test',
          photoUrl: '',
          title: 'Flutter Dev',
          createdAt: DateTime(2024, 3, 1),
          isOnline: true,
          lastSeen: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),

            // HomePage utilise currentUserProvider.
            currentUserProvider.overrideWithValue(user),

            // ProfilePage utilise directement authStateProvider.
            authStateProvider.overrideWith((ref) => Stream.value(user)),

            // Conversations affichées dans HomePage / ChatsPage.
            userChatsProvider(user.id).overrideWith((ref) => Stream.value([])),

            // Données du profil utilisées par ProfilePage.
            profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          ],
          child: const MaterialApp(home: HomePage()),
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

      expect(find.text('Déconnexion'), findsOneWidget);
    });
  });
}
