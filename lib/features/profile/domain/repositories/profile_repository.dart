import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  Future<ProfileEntity?> getProfile(String userId);

  Future<void> saveProfile(ProfileEntity profile);

  Future<ProfileEntity> updateProfile({
    required String name,
    String? avatarUrl,
    String? email,
    String? bio,
  });
}
