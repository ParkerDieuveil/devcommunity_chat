import '../repositories/chat_repository.dart';

class CreateChatUseCase {
  final ChatRepository repository;

  CreateChatUseCase(this.repository);

  Future<String> call(
    List<String> participantIds, {
    String? name,
  }) {
    return repository.createChat(participantIds, name: name);
  }
}
