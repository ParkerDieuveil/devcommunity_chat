import '../entities/chat_media_image.dart';
import '../exceptions/chat_media_exceptions.dart';

abstract final class ChatMediaConstraints {
  static const int maxSourceBytes = 15 * 1024 * 1024;
  static const int maxProcessedBytes = 2 * 1024 * 1024;
  static const int maxDimensionPx = 1600;
  static const int jpegQuality = 85;

  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
  };
}

class ChatMediaValidator {
  const ChatMediaValidator();

  void validateRaw(RawChatImage image) {
    if (image.bytes.isEmpty) {
      throw const ChatMediaValidationException('Le fichier image est vide.');
    }
    if (image.sizeInBytes > ChatMediaConstraints.maxSourceBytes) {
      throw const ChatMediaValidationException(
        'L’image dépasse 15 Mo. Choisis-en une plus légère.',
      );
    }
    final mime = image.mimeType?.toLowerCase();
    if (mime != null &&
        mime.isNotEmpty &&
        !ChatMediaConstraints.allowedMimeTypes.contains(mime)) {
      throw ChatMediaValidationException(
        'Format non supporté ($mime). Utilise JPG, PNG ou WebP.',
      );
    }
  }

  void validateProcessed(ProcessedChatImage image) {
    if (image.bytes.isEmpty) {
      throw const ChatMediaValidationException('Image traitée invalide.');
    }
    if (image.sizeInBytes > ChatMediaConstraints.maxProcessedBytes) {
      throw const ChatMediaValidationException(
        'Impossible de compresser l’image sous 2 Mo.',
      );
    }
  }
}
