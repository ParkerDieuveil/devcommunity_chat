import '../entities/message_entity.dart';
import '../entities/messages_page.dart';
import '../repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(
    String chatId, {
    int limit = kMessagePageSize,
  }) {
    return repository.watchMessages(chatId, limit: limit);
  }
}
