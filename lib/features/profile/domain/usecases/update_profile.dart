import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<ProfileEntity> call({
    required String userId,
    required String name,
    String? avatarUrl,
    String? email,
    String? bio,
    String? title,
  }) {
    return repository.updateProfile(
      userId: userId,
      name: name,
      photoUrl: avatarUrl,
      email: email,
      bio: bio,
      title: title,
    );
  }
}
