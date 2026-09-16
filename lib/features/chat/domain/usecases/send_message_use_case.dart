import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  }) {
    return repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
    );
  }
}
