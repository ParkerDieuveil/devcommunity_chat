import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileEntity? profile;

  int updateProfileCallCount = 0;
  int updatePushCallCount = 0;
  String? lastUserId;
  String? lastName;
  String? lastEmail;
  String? lastBio;
  String? lastTitle;
  bool? lastPushEnabled;

  FakeProfileRepository({this.profile});

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    return profile;
  }

  @override
  Stream<ProfileEntity?> watchProfile(String userId) {
    return Stream.value(profile);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String userId,
    required String name,
    String? photoUrl,
    String? email,
    String? bio,
    String? title,
  }) async {
    updateProfileCallCount++;
    lastUserId = userId;
    lastName = name;
    lastEmail = email;
    lastBio = bio;
    lastTitle = title;

    profile = ProfileEntity(
      id: userId,
      displayname: name,
      photoUrl: photoUrl ?? profile?.photoUrl ?? '',
      email: email ?? profile?.email ?? '',
      bio: bio ?? profile?.bio ?? '',
      title: title ?? profile?.title ?? '',
      pushNotificationsEnabled: profile?.pushNotificationsEnabled ?? true,
      createdAt: profile?.createdAt,
      lastSeen: profile?.lastSeen,
      isOnline: profile?.isOnline ?? false,
    );

    return profile!;
  }

  @override
  Future<void> updatePushNotifications({
    required String userId,
    required bool enabled,
  }) async {
    updatePushCallCount++;
    lastUserId = userId;
    lastPushEnabled = enabled;
    if (profile != null) {
      profile = profile!.copyWith(pushNotificationsEnabled: enabled);
    }
  }

  @override
  Future<ProfileEntity> updatePhotoUrl({
    required String userId,
    required String photoUrl,
  }) async {
    lastUserId = userId;
    profile = (profile ??
            ProfileEntity(
              id: userId,
              displayname: '',
              email: '',
              bio: '',
              photoUrl: '',
            ))
        .copyWith(photoUrl: photoUrl);
    return profile!;
  }

  @override
  Future<void> saveProfile(ProfileEntity profile) async {
    this.profile = profile;
  }

  @override
  Stream<List<ProfileEntity>> watchProfiles() {
    return Stream.value(profile != null ? [profile!] : []);
  }
}
