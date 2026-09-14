import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_push_notifications.dart';
import '../../domain/usecases/watch_profile.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((
  ref,
) {
  return ProfileRemoteDatasource(FirebaseFirestore.instance);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileRemoteDatasourceProvider),
  );
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

/// Liste en temps réel des profils enregistrés dans Firestore.
final profilesProvider = StreamProvider<List<ProfileEntity>>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfiles();
});

/// Profil Firestore de l’utilisateur connecté (bio, titre, préférences…).
final currentUserProfileProvider = StreamProvider<ProfileEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(null);
  }
  return ref.watch(watchProfileProvider).call(user.id);
});

/// Nombre de salons (chats) de l’utilisateur connecté.
final profileSalonCountProvider = Provider<AsyncValue<int>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const AsyncData(0);
  }
  return ref.watch(userChatsProvider(user.id)).whenData((chats) => chats.length);
});
