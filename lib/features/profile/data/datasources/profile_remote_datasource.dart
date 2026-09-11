import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devcommunitychat/features/profile/data/models/profile_model.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore firestore;

  ProfileRemoteDatasource(this.firestore);

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final snapshot = await firestore.collection('users').doc(userId).get();

    return snapshot.data();
  }

  Future<void> saveProfile(ProfileModel profile) {
    return firestore.collection('users').doc(profile.id).set(profile.toJson());
  }
}
