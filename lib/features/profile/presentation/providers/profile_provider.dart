import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/datasources/profile_storage_datasource.dart';
import '../../data/pipeline/sync_auth_photo_url_step.dart';
import '../../data/processors/jpeg_avatar_image_processor.dart';
import '../../data/repositories/profile_avatar_storage_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/sources/gallery_avatar_image_source.dart';
import '../../domain/entities/profile.dart';
import '../../domain/pipeline/avatar_update_pipeline.dart';
import '../../domain/pipeline/steps/avatar_pipeline_steps.dart';
import '../../domain/repositories/profile_avatar_storage.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/services/avatar_image_processor.dart';
import '../../domain/services/avatar_image_source.dart';
import '../../domain/services/avatar_validator.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_profile_avatar.dart';
import '../../domain/usecases/update_push_notifications.dart';
import '../../domain/usecases/watch_profile.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((
  ref,
) {
  return ProfileRemoteDatasource(FirebaseFirestore.instance);
});

final profileStorageDatasourceProvider = Provider<ProfileStorageDatasource>((
  ref,
) {
  return ProfileStorageDatasource(FirebaseStorage.instance);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDatasourceProvider),
  );
});

final profileAvatarStorageProvider = Provider<ProfileAvatarStorage>((ref) {
  return ProfileAvatarStorageImpl(
    ref.watch(profileStorageDatasourceProvider),
  );
});

final avatarImageSourceProvider = Provider<AvatarImageSource>((ref) {
  return GalleryAvatarImageSource();
});

final avatarImageProcessorProvider = Provider<AvatarImageProcessor>((ref) {
  return const JpegAvatarImageProcessor();
});

final avatarValidatorProvider = Provider<AvatarValidator>((ref) {
  return const AvatarValidator();
});

final avatarUpdatePipelineProvider = Provider<AvatarUpdatePipeline>((ref) {
  final profiles = ref.watch(profileRepositoryProvider);
  final storage = ref.watch(profileAvatarStorageProvider);
  final source = ref.watch(avatarImageSourceProvider);
  final processor = ref.watch(avatarImageProcessorProvider);
  final validator = ref.watch(avatarValidatorProvider);

  return AvatarUpdatePipeline([
    LoadPreviousPhotoStep(profiles),
    PickAvatarStep(source),
    ValidateRawAvatarStep(validator),
    ProcessAvatarStep(processor, validator),
    UploadAvatarStep(storage),
    PersistAvatarUrlStep(profiles),
    CleanupPreviousAvatarStep(storage),
    SyncAuthPhotoUrlStep(ref.watch(firebaseAuthProvider)),
  ]);
});

final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
});

final watchProfileProvider = Provider<WatchProfile>((ref) {
  return WatchProfile(ref.watch(profileRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
});

final updatePushNotificationsProvider = Provider<UpdatePushNotifications>((
  ref,
) {
  return UpdatePushNotifications(ref.watch(profileRepositoryProvider));
});

final updateProfileAvatarProvider = Provider<UpdateProfileAvatar>((ref) {
  return UpdateProfileAvatar(ref.watch(avatarUpdatePipelineProvider));
});

final profilesProvider = StreamProvider<List<ProfileEntity>>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfiles();
});

final currentUserProfileProvider = StreamProvider<ProfileEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(watchProfileProvider).call(user.id);
});

final profileSalonCountProvider = Provider<AsyncValue<int>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const AsyncData(0);
  }
  return ref.watch(userChatsProvider(user.id)).whenData((chats) => chats.length);
});

final profileAvatarControllerProvider =
    NotifierProvider<ProfileAvatarController, AsyncValue<void>>(
  ProfileAvatarController.new,
);

class ProfileAvatarController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// `true` si upload OK, `false` si annulé, exception via [state] si échec.
  Future<bool> changeAvatar(AvatarPickSource source) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    state = const AsyncLoading();
    try {
      final updated = await ref.read(updateProfileAvatarProvider).call(
            userId: user.id,
            source: source,
          );
      state = const AsyncData(null);
      return updated != null;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
