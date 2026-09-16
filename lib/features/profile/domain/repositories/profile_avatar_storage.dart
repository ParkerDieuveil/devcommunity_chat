import '../entities/avatar_image.dart';

abstract interface class ProfileAvatarStorage {
  Future<String> uploadAvatar({
    required String userId,
    required ProcessedAvatarImage image,
  });

  /// Supprime un ancien objet Storage si l’URL appartient à ce bucket / user.
  Future<void> deleteOwnedAvatarUrl(String? photoUrl);
}
