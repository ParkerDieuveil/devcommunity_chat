import '../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<void> call({
    required String chatId,
    required String userId,
  }) {
    return repository.markMessagesAsRead(
      chatId: chatId,
      userId: userId,
    );
  }
}