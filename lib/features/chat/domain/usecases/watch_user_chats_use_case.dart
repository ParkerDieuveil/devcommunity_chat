import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class WatchUserChatsUseCase {
  final ChatRepository repository;

  WatchUserChatsUseCase(this.repository);

  Stream<List<ChatEntity>> call(String userId) {
    return repository.watchUserChats(userId);
  }
}
