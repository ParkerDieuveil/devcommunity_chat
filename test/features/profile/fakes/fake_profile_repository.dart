import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileCall {
  final String userId;
  final String name;
  final String? photoUrl;
  final String? email;
  final String? bio;

  UpdateProfileCall({
    required this.userId,
    required this.name,
    this.photoUrl,
    this.email,
    this.bio,
  });
}

/// Fake en mémoire de [ProfileRepository], utilisé pour tester la
/// modification de profil sans dépendre de Firestore.
class FakeProfileRepository implements ProfileRepository {
  final List<UpdateProfileCall> updateCalls = [];
  Exception? updateProfileError;
  ProfileEntity? profileToReturn;

  @override
  Future<ProfileEntity?> getProfile(String userId) async => profileToReturn;

  @override
  Future<void> saveProfile(ProfileEntity profile) async {}

  @override
  Future<ProfileEntity> updateProfile({
    required String userId,
    required String name,
    String? photoUrl,
    String? email,
    String? bio,
  }) async {
    updateCalls.add(
      UpdateProfileCall(
        userId: userId,
        name: name,
        photoUrl: photoUrl,
        email: email,
        bio: bio,
      ),
    );

    if (updateProfileError != null) {
      throw updateProfileError!;
    }

    return ProfileEntity(
      id: userId,
      displayname: name,
      email: email ?? '',
      bio: bio ?? '',
      photoUrl: photoUrl ?? '',
    );
  }
}
