import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Stream<ProfileEntity?> watchProfile(String userId);

  Stream<List<ProfileEntity>> watchProfiles();

  Future<void> saveProfile(ProfileEntity profile);

  Future<ProfileEntity> updateProfile({
    required String userId,
    required String name,
    String? photoUrl,
    String? email,
    String? bio,
    String? title,
  });

  Future<void> updatePushNotifications({
    required String userId,
    required bool enabled,
  });

  Future<ProfileEntity> updatePhotoUrl({
    required String userId,
    required String photoUrl,
  });
}
