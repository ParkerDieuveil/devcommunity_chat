import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String chatId) {
    return repository.watchMessages(chatId);
  }
}
