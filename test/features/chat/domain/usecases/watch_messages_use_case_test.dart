import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/chat/domain/entities/message_entity.dart';
import 'package:devcommunitychat/features/chat/domain/usecases/watch_messages_use_case.dart';

import '../../fakes/fake_chat_repository.dart';

MessageEntity _message(String id) => MessageEntity(
  messageId: id,
  chatId: 'chat-1',
  senderId: 'user-1',
  text: 'message $id',
  type: MessageType.text,
  timestamp: DateTime(2026, 1, 1),
);

void main() {
  group('WatchMessagesUseCase', () {
    test('retransmet en temps réel les messages émis par le repository', () {
      final repository = FakeChatRepository();
      final useCase = WatchMessagesUseCase(repository);

      final firstBatch = [_message('1')];
      final secondBatch = [_message('1'), _message('2')];

      expect(
        useCase.call('chat-1'),
        emitsInOrder([firstBatch, secondBatch]),
      );

      repository.emitMessages(firstBatch);
      repository.emitMessages(secondBatch);
    });
  });
}
