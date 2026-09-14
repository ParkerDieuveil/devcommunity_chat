import '../entities/avatar_image.dart';

/// Redimensionne / ré-encode l’avatar avant upload.
abstract interface class AvatarImageProcessor {
  Future<ProcessedAvatarImage> process(RawAvatarImage raw);
}
