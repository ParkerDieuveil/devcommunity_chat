import '../entities/avatar_image.dart';
import '../exceptions/profile_exceptions.dart';

/// Règles métier d’acceptation d’une image source.
abstract final class AvatarConstraints {
  static const int maxSourceBytes = 15 * 1024 * 1024;
  static const int maxProcessedBytes = 2 * 1024 * 1024;
  static const int maxDimensionPx = 1024;
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

class AvatarValidator {
  const AvatarValidator();

  void validateRaw(RawAvatarImage image) {
    if (image.bytes.isEmpty) {
      throw const AvatarValidationException('Le fichier image est vide.');
    }

    if (image.sizeInBytes > AvatarConstraints.maxSourceBytes) {
      throw const AvatarValidationException(
        'L’image dépasse 15 Mo. Choisis-en une plus légère.',
      );
    }

    final mime = image.mimeType?.toLowerCase();
    if (mime != null &&
        mime.isNotEmpty &&
        !AvatarConstraints.allowedMimeTypes.contains(mime)) {
      throw AvatarValidationException(
        'Format non supporté ($mime). Utilise JPG, PNG ou WebP.',
      );
    }
  }

  void validateProcessed(ProcessedAvatarImage image) {
    if (image.bytes.isEmpty) {
      throw const AvatarValidationException('Image traitée invalide.');
    }
    if (image.sizeInBytes > AvatarConstraints.maxProcessedBytes) {
      throw const AvatarValidationException(
        'Impossible de compresser l’image sous 2 Mo.',
      );
    }
  }
}
