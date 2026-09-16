import '../../domain/entities/chat_media_image.dart';
import '../../domain/repositories/chat_media_storage.dart';
import '../datasources/chat_storage_datasource.dart';

class ChatMediaStorageImpl implements ChatMediaStorage {
  final ChatStorageDatasource datasource;

  ChatMediaStorageImpl(this.datasource);

  @override
  Future<String> uploadImage({
    required String chatId,
    required String senderId,
    required ProcessedChatImage image,
  }) {
    return datasource.uploadImage(
      chatId: chatId,
      senderId: senderId,
      image: image,
    );
  }

  @override
  Future<String> uploadAudio({
    required String chatId,
    required String senderId,
    required String localPath,
    String contentType = 'audio/m4a',
    String fileExtension = 'm4a',
  }) {
    return datasource.uploadAudio(
      chatId: chatId,
      senderId: senderId,
      localPath: localPath,
      contentType: contentType,
      fileExtension: fileExtension,
    );
  }
}
