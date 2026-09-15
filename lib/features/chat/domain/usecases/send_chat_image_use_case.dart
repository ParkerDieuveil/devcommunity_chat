import '../entities/chat_media_image.dart';
import '../exceptions/chat_media_exceptions.dart';
import '../repositories/chat_media_storage.dart';
import '../repositories/chat_repository.dart';
import '../services/chat_media_image_processor.dart';
import '../services/chat_media_image_source.dart';
import '../services/chat_media_validator.dart';

/// Pick → validate → process → Storage → Firestore message (`type: image`).
class SendChatImageUseCase {
  final ChatMediaImageSource imageSource;
  final ChatMediaValidator validator;
  final ChatMediaImageProcessor processor;
  final ChatMediaStorage mediaStorage;
  final ChatRepository chatRepository;

  SendChatImageUseCase({
    required this.imageSource,
    required this.validator,
    required this.processor,
    required this.mediaStorage,
    required this.chatRepository,
  });

  /// Retourne `false` si l’utilisateur annule le sélecteur.
  Future<bool> call({
    required String chatId,
    required String senderId,
    required ChatMediaPickSource source,
    String? caption,
  }) async {
    final raw = await imageSource.pick(source);
    if (raw == null) {
      return false;
    }

    try {
      validator.validateRaw(raw);
      final processed = await processor.process(raw);
      validator.validateProcessed(processed);

      final imageUrl = await mediaStorage.uploadImage(
        chatId: chatId,
        senderId: senderId,
        image: processed,
      );

      final trimmedCaption = caption?.trim();
      await chatRepository.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: (trimmedCaption != null && trimmedCaption.isNotEmpty)
            ? trimmedCaption
            : null,
        imageUrl: imageUrl,
      );
      return true;
    } on ChatMediaException {
      rethrow;
    } catch (error) {
      throw ChatMediaUploadException('Échec de l’envoi de l’image : $error');
    }
  }
}
