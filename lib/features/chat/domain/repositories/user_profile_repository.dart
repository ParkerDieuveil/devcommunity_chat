import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<void> createOrUpdateUserProfile(UserProfileEntity profile);

  Future<void> setUserOffline(String uid);
}
