import '../exceptions/chat_media_exceptions.dart';
import '../repositories/chat_media_storage.dart';
import '../repositories/chat_repository.dart';

/// Upload d’un fichier audio local → Storage → message Firestore (`type: audio`).
class SendChatAudioUseCase {
  final ChatMediaStorage mediaStorage;
  final ChatRepository chatRepository;

  SendChatAudioUseCase({
    required this.mediaStorage,
    required this.chatRepository,
  });

  Future<void> call({
    required String chatId,
    required String senderId,
    required String localPath,
  }) async {
    try {
      final audioUrl = await mediaStorage.uploadAudio(
        chatId: chatId,
        senderId: senderId,
        localPath: localPath,
      );

      await chatRepository.sendMessage(
        chatId: chatId,
        senderId: senderId,
        audioUrl: audioUrl,
      );
    } on ChatMediaException {
      rethrow;
    } catch (error) {
      throw ChatMediaUploadException('Échec de l’envoi de l’audio : $error');
    }
  }
}
