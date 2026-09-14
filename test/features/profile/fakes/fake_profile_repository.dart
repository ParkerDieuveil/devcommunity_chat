import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileEntity? profile;
  
  int updateProfileCallCount = 0;
  String? lastUserId;
  String? lastName;
  String? lastEmail;
  String? lastBio;

  FakeProfileRepository({this.profile});

  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    return profile;
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String userId,
    required String name,
    String? photoUrl,
    String? email,
    String? bio,
  }) async {
    updateProfileCallCount++;
    lastUserId = userId;
    lastName = name;
    lastEmail = email;
    lastBio = bio;

    profile = ProfileEntity(
      id: userId,
      displayname: name,
      photoUrl: photoUrl ?? profile?.photoUrl ?? '',
      email: email ?? profile?.email ?? '',
      bio: bio ?? profile?.bio ?? '',
    );
    
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
