import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatUseCase {
  final ChatRepository repository;

  GetChatUseCase(this.repository);

  Future<ChatEntity?> call(String chatId) {
    return repository.getChat(chatId);
  }
}