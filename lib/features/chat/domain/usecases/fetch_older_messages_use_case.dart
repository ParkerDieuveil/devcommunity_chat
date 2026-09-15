import '../entities/messages_page.dart';
import '../repositories/chat_repository.dart';

class FetchOlderMessagesUseCase {
  final ChatRepository repository;

  FetchOlderMessagesUseCase(this.repository);

  Future<MessagesPage> call({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  }) {
    return repository.fetchOlderMessages(
      chatId: chatId,
      beforeMessageId: beforeMessageId,
      limit: limit,
    );
  }
}
