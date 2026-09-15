import '../../domain/entities/avatar_image.dart';
import '../../domain/repositories/profile_avatar_storage.dart';
import '../datasources/profile_storage_datasource.dart';

class ProfileAvatarStorageImpl implements ProfileAvatarStorage {
  final ProfileStorageDatasource datasource;

  ProfileAvatarStorageImpl(this.datasource);

  @override
  Future<String> uploadAvatar({
    required String userId,
    required ProcessedAvatarImage image,
  }) {
    return datasource.uploadAvatar(userId: userId, image: image);
  }

  @override
  Future<void> deleteOwnedAvatarUrl(String? photoUrl) async {
    if (photoUrl == null || photoUrl.trim().isEmpty) return;

    final decoded = Uri.decodeFull(photoUrl);
    final isOwnedAvatar =
        decoded.contains('/users/') && decoded.contains('/avatar/');
    if (!isOwnedAvatar) return;

    await datasource.deleteByDownloadUrl(photoUrl);
  }
}
