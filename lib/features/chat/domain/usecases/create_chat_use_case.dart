import '../repositories/chat_repository.dart';

class CreateChatUseCase {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<String> call(List<String> participantIds) {
    return repository.createChat(participantIds);
  }
}
