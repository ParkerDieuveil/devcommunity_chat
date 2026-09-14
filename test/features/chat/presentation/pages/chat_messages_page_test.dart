import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/domain/entities/message_entity.dart';
import 'package:devcommunitychat/features/chat/presentation/pages/chat_messages_page.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';

import '../../fakes/fake_chat_repository.dart';

const _user = AppUser(id: 'user-1', email: 'user@example.com');

void main() {
  group('ChatMessagesPage', () {
    late FakeChatRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeChatRepository();
    });

    Future<void> pumpPage(WidgetTester tester) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            chatRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ChatMessagesPage(chatId: 'chat-1'),
          ),
        ),
      );
    }

    testWidgets('affiche un loader puis "Aucun message" si le chat est vide', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      fakeRepository.emitMessages([]);
      await tester.pump();

      expect(find.text('Aucun message'), findsOneWidget);
    });

    testWidgets('affiche les messages reçus en temps réel', (tester) async {
      await pumpPage(tester);
      fakeRepository.emitMessages([]);
      await tester.pump();

      expect(find.text('Salut !'), findsNothing);

      fakeRepository.emitMessages([
        MessageEntity(
          messageId: 'm1',
          chatId: 'chat-1',
          senderId: 'other-user',
          text: 'Salut !',
          type: MessageType.text,
          timestamp: DateTime(2026, 1, 1),
        ),
      ]);
      await tester.pump();

      expect(find.text('Salut !'), findsOneWidget);
    });

    testWidgets(
      'envoyer un message appelle le repository et vide le champ de saisie',
      (tester) async {
        await pumpPage(tester);
        fakeRepository.emitMessages([]);
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'Ca avance bien');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        await tester.pump();

        expect(fakeRepository.sentMessages, hasLength(1));
        final sent = fakeRepository.sentMessages.single;
        expect(sent.chatId, 'chat-1');
        expect(sent.senderId, 'user-1');
        expect(sent.text, 'Ca avance bien');

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      },
    );

    testWidgets('un envoi qui échoue affiche un message d\'erreur', (
      tester,
    ) async {
      fakeRepository.sendMessageError = Exception('Erreur réseau');

      await pumpPage(tester);
      fakeRepository.emitMessages([]);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Ca ne va pas passer');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Erreur réseau'), findsOneWidget);
    });
  });
}
