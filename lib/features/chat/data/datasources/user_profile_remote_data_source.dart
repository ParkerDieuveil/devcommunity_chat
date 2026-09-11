import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<void> createOrUpdateUserProfile(UserProfileModel profile);

  Future<void> setUserOffline(String uid);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  UserProfileRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<void> createOrUpdateUserProfile(UserProfileModel profile) async {
    final docRef = _users.doc(profile.uid);
    final existing = await docRef.get();
    final data = profile.toMap();

    // createdAt figé après la 1ère écriture.
    if (existing.exists) {
      data.remove('createdAt');
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> setUserOffline(String uid) async {
    await _users.doc(uid).set(
      {
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
