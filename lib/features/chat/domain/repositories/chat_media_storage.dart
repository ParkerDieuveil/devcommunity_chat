import '../entities/chat_media_image.dart';

abstract interface class ChatMediaStorage {
  /// Upload vers `chats/{chatId}/images/{fileName}` et retourne l’URL.
  Future<String> uploadImage({
    required String chatId,
    required String senderId,
    required ProcessedChatImage image,
  });

  /// Upload vers `chats/{chatId}/audio/{fileName}` et retourne l’URL.
  Future<String> uploadAudio({
    required String chatId,
    required String senderId,
    required String localPath,
    String contentType = 'audio/m4a',
    String fileExtension = 'm4a',
  });
}
