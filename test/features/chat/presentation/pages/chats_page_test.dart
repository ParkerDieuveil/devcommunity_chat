import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/domain/entities/chat_entity.dart';
import 'package:devcommunitychat/features/chat/presentation/pages/chats_page.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../fakes/fake_chat_repository.dart';

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

    Future<void> pumpPage(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
                  (ref) => Stream.value(_user),
            ),
            chatRepositoryProvider.overrideWithValue(
              fakeRepository,
            ),
            profilesProvider.overrideWith(
                  (ref) => Stream.value([
                ProfileEntity(
                  id: 'user-2',
                  displayname: 'Jean Dupont',
                  email: 'jean@example.com',
                  bio: '',
                  photoUrl: '',
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: ChatsPage(),
          ),
        ),
      );
    }

    testWidgets(
      'affiche "Aucune conversation" si la liste est vide',
          (tester) async {
        await pumpPage(tester);
        await tester.pump();

        fakeRepository.emitChats([]);
        await tester.pump();

        expect(
          find.text('Aucune conversation'),
          findsOneWidget,
        );
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

        expect(
          find.text('Jean Dupont'),
          findsOneWidget,
        );

        expect(
          find.text('A demain !'),
          findsOneWidget,
        );
      },
    );
  });
}