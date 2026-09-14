sealed class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);

  @override
  String toString() => message;
}

/// L’utilisateur a fermé le sélecteur sans choisir d’image.
final class AvatarSelectionCancelled extends ProfileException {
  const AvatarSelectionCancelled() : super('Sélection d’avatar annulée.');
}

final class AvatarValidationException extends ProfileException {
  const AvatarValidationException(super.message);
}

final class AvatarProcessingException extends ProfileException {
  const AvatarProcessingException(super.message);
}

final class AvatarUploadException extends ProfileException {
  const AvatarUploadException(super.message);
}

final class ProfileNotFoundException extends ProfileException {
  const ProfileNotFoundException(String userId)
      : super('Profil introuvable pour $userId.');
}
