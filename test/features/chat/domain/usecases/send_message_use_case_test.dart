import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/chat/domain/usecases/send_message_use_case.dart';

import '../../fakes/fake_chat_repository.dart';

void main() {
  group('SendMessageUseCase', () {
    test('délègue au repository avec les bons paramètres', () async {
      final repository = FakeChatRepository();
      final useCase = SendMessageUseCase(repository);

      await useCase.call(
        chatId: 'chat-1',
        senderId: 'user-1',
        text: 'Salut !',
      );

      expect(repository.sentMessages, hasLength(1));
      final sent = repository.sentMessages.single;
      expect(sent.chatId, 'chat-1');
      expect(sent.senderId, 'user-1');
      expect(sent.text, 'Salut !');
      expect(sent.imageUrl, isNull);
    });

    test('propage l\'erreur du repository', () {
      final repository = FakeChatRepository()
        ..sendMessageError = Exception('Erreur réseau');
      final useCase = SendMessageUseCase(repository);

      expect(
        () => useCase.call(chatId: 'chat-1', senderId: 'user-1', text: 'Hi'),
        throwsException,
      );
    });
  });
}
