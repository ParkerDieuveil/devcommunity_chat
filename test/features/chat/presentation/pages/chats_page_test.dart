import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/domain/entities/chat_entity.dart';
import 'package:devcommunitychat/features/chat/presentation/pages/chats_page.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../fakes/fake_chat_repository.dart';
import '../../../../helpers/test_prefs.dart';

const _user = AppUser(
  id: 'user-1',
  email: 'user@example.com',
);

void main() {
  group('ChatsPage', () {
    late FakeChatRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeChatRepository();
    });

    Future<void> pumpPage(WidgetTester tester) async {
      final prefs = await mockSharedPreferences();
      final router = GoRouter(
        initialLocation: AppRoutePath.chatsPath,
        routes: [
          GoRoute(
            path: AppRoutePath.chatsPath,
            builder: (_, _) => const ChatsPage(),
          ),
          GoRoute(
            path: AppRoutePath.newChatPath,
            builder: (_, _) => const Scaffold(body: Text('New chat stub')),
          ),
          GoRoute(
            path: AppRoutePath.createGroupPath,
            builder: (_, _) => const Scaffold(body: Text('Create group stub')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith(
              (ref) => Stream.value(_user),
            ),
            chatRepositoryProvider.overrideWithValue(
              fakeRepository,
            ),
            profilesProvider.overrideWith(
              (ref) => Stream.value([
                const ProfileEntity(
                  id: 'user-2',
                  displayname: 'Jean Dupont',
                  email: 'jean@example.com',
                  bio: '',
                  photoUrl: '',
                ),
              ]),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
    }

    testWidgets(
      'affiche un empty state si la liste est vide',
      (tester) async {
        await pumpPage(tester);
        await tester.pump();

        fakeRepository.emitChats([]);
        await tester.pump();

        expect(find.text('Aucune discussion'), findsOneWidget);
        expect(find.text('Nouvelle discussion'), findsOneWidget);
      },
    );

    testWidgets(
      'le + ouvre le menu Ajouter un contact / Créer un groupe',
      (tester) async {
        await pumpPage(tester);
        await tester.pump();
        fakeRepository.emitChats([]);
        await tester.pump();

        await tester.tap(find.byTooltip('Ajouter'));
        await tester.pumpAndSettle();

        expect(find.text('Ajouter un contact'), findsOneWidget);
        expect(find.text('Créer un groupe'), findsOneWidget);
      },
    );

    testWidgets(
      'affiche les conversations reçues en temps réel',
      (tester) async {
        await pumpPage(tester);
        await tester.pump();

        fakeRepository.emitChats([]);
        await tester.pump();

        fakeRepository.emitChats([
          ChatEntity(
            chatId: 'chat-1',
            participantIds: const [
              'user-1',
              'user-2',
            ],
            lastMessage: 'A demain !',
            createdAt: DateTime(2026, 1, 1),
          ),
        ]);

        await tester.pump();

        expect(find.text('Jean Dupont'), findsOneWidget);
        expect(find.text('A demain !'), findsOneWidget);
      },
    );
  });
}
