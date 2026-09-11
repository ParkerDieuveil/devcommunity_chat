import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<ProfileEntity> call({
    required String name,
    String? avatarUrl,
    String? email,
    String? bio,
  }) {
    return repository.updateProfile(
      name: name,
      avatarUrl: avatarUrl,
      email: email,
      bio: bio,
    );
  }
}
