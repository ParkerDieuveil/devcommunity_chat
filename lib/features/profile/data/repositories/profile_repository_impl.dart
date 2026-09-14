import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

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
  Stream<ProfileEntity?> watchProfile(String userId) {
    return datasource.watchProfile(userId);
  }

  @override
  Stream<List<ProfileEntity>> watchProfiles() {
    return datasource.watchProfiles();
  }

  @override
  Future<void> saveProfile(ProfileEntity profile) {
    return datasource.saveProfile(ProfileModel.fromEntity(profile));
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
    final existing = await getProfile(userId);

    final updatedProfile = ProfileModel(
      id: userId,
      displayname: name,
      photoUrl: photoUrl ?? existing?.photoUrl ?? '',
      email: email ?? existing?.email ?? '',
      bio: bio ?? existing?.bio ?? '',
      title: title ?? existing?.title ?? '',
      pushNotificationsEnabled: existing?.pushNotificationsEnabled ?? true,
      createdAt: existing?.createdAt,
      lastSeen: existing?.lastSeen,
      isOnline: existing?.isOnline ?? false,
    );

    await datasource.updateProfile(userId, updatedProfile.toJson());

    return updatedProfile;
  }

  @override
  Future<void> updatePushNotifications({
    required String userId,
    required bool enabled,
  }) {
    return datasource.updateProfile(userId, {
      'pushNotificationsEnabled': enabled,
    });
  }
}
