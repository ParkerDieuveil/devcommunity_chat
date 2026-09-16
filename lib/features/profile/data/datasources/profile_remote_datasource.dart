import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore firestore;

  ProfileRemoteDatasource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final snapshot = await _users.doc(userId).get();
    return snapshot.data();
  }

  Stream<ProfileModel?> watchProfile(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return null;
      }
      return ProfileModel.fromJson({...data, 'id': snapshot.id});
    });
  }

  Stream<List<ProfileModel>> watchProfiles() {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => ProfileModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    });
  }

  Future<void> saveProfile(ProfileModel profile) {
    return _users.doc(profile.id).set(profile.toJson());
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data, SetOptions(merge: true));
  }
}
