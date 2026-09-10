import '../../../auth/domain/entities/app_user.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class SyncUserProfileUseCase {
  final UserProfileRepository repository;

  SyncUserProfileUseCase(this.repository);

  Future<void> call(AppUser user) {
    final now = DateTime.now();
    final profile = UserProfileEntity(
      uid: user.id,
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : user.email.split('@').first,
      email: user.email,
      photoUrl: user.photoUrl,
      createdAt: now,
      lastSeen: now,
      isOnline: true,
    );

    return repository.createOrUpdateUserProfile(profile);
  }
}
