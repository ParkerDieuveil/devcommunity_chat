import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/chat/domain/entities/message_entity.dart';
import 'package:devcommunitychat/features/chat/presentation/pages/chat_messages_page.dart';
import 'package:devcommunitychat/features/chat/presentation/providers/chat_provider.dart';

import '../../fakes/fake_chat_repository.dart';
import '../../../../helpers/test_prefs.dart';

const _user = AppUser(id: 'user-1', email: 'user@example.com');

void main() {
  group('ChatMessagesPage', () {
    late FakeChatRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeChatRepository();
    });

    Future<void> pumpPage(WidgetTester tester) async {
      final prefs = await mockSharedPreferences();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith((ref) => Stream.value(_user)),
            chatRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ChatMessagesPage(chatId: 'chat-1'),
          ),
        ),
      );
    }

    Future<void> tapSend(WidgetTester tester) async {
      final sendButton = find.byType(SvgPicture);
      if (sendButton.evaluate().isNotEmpty) {
        await tester.tap(sendButton.last);
      } else {
        await tester.testTextInput.receiveAction(TextInputAction.send);
      }
    }

    testWidgets(
      'affiche un loader puis empty state si le chat est vide',
      (tester) async {
        await pumpPage(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        fakeRepository.emitMessages([]);
        await tester.pump();

        expect(find.text('Envoyez le premier message'), findsOneWidget);
      },
    );

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
        await tapSend(tester);
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
      await tapSend(tester);
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Erreur réseau'), findsOneWidget);
    });
  });
}
