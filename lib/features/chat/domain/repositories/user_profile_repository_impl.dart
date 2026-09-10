import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../data/models/user_profile_model.dart';
import '../entities/user_profile_entity.dart';
import '../exceptions/chat_exceptions.dart';
import 'user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createOrUpdateUserProfile(UserProfileEntity profile) async {
    try {
      await remoteDataSource.createOrUpdateUserProfile(
        UserProfileModel.fromEntity(profile),
      );
    } catch (error) {
      throw _wrap(error, 'Impossible de synchroniser le profil utilisateur.');
    }
  }

  @override
  Future<void> setUserOffline(String uid) async {
    try {
      await remoteDataSource.setUserOffline(uid);
    } catch (error) {
      throw _wrap(error, 'Impossible de mettre le profil hors ligne.');
    }
  }

  Never _wrap(Object error, String fallbackMessage) {
    if (error is ChatRepositoryException) {
      throw error;
    }

    if (error is FirebaseException) {
      throw ChatRepositoryException(
        error.message ?? fallbackMessage,
        cause: error,
      );
    }

    throw ChatRepositoryException(fallbackMessage, cause: error);
  }
}
