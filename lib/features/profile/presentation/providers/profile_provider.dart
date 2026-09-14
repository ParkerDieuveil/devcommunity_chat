import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile.dart';

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

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(
    ref.watch(profileRepositoryProvider),
  );
});

/// Liste en temps réel des profils enregistrés dans Firestore.
final profilesProvider = StreamProvider<List<ProfileEntity>>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfiles();
});