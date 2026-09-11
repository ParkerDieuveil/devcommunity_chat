import 'package:devcommunitychat/features/profile/domain/repositories/profile_repository.dart';
import 'package:devcommunitychat/features/profile/data/models/profile_model.dart';
import 'package:devcommunitychat/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource datasource;

  ProfileRepositoryImpl(this.datasource);

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await datasource.getProfile(userId);

    if (data == null) {
      throw Exception('Profile not found for userId: $userId');
    }

    return ProfileModel.fromJson({...data, 'id': userId});
  }

  @override
  Future<void> saveProfile(ProfileEntity profile) {
    final model = ProfileModel.fromEntity(profile);

    return datasource.saveProfile(model);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String name,
    String? avatarUrl,
    String? email,
    String? bio,
  }) async {
    // Assuming you have a way to get the current user's ID
    final userId =
        'currentUserId'; // Replace with actual logic to get current user ID

    final profile = await getProfile(userId);

    if (profile == null) {
      throw Exception('Profile not found for userId: $userId');
    }

    final updatedProfile = ProfileModel(
      id: profile.id,
      displayname: name,
      avatarUrl: avatarUrl ?? profile.avatarUrl,
      email: email ?? profile.email,
      bio: bio ?? profile.bio,
    );

    await saveProfile(updatedProfile);

    return updatedProfile;
  }
}
