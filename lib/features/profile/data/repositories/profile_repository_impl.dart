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
      return null;
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
    required String userId,
    required String name,
    String? photoUrl,
    String? email,
    String? bio,
  }) async {
    final profile = await getProfile(userId);

    if (profile == null) {
      throw Exception('Profile not found for userId: $userId');
    }

    final updatedProfile = ProfileModel(
      id: userId,
      displayname: name,
      photoUrl: photoUrl ?? profile.photoUrl,
      email: email ?? profile.email,
      bio: bio ?? profile.bio,
    );

    await datasource.updateProfile(userId, updatedProfile.toJson());

    return updatedProfile;
  }
}
