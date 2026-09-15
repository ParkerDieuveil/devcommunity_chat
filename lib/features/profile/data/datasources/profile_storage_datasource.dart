import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/avatar_image.dart';
import '../../domain/exceptions/profile_exceptions.dart';

class ProfileStorageDatasource {
  final FirebaseStorage storage;

  ProfileStorageDatasource(this.storage);

  Reference avatarRef(String userId) {
    return storage.ref().child('users').child(userId).child('avatar').child(
          'profile.jpg',
        );
  }

  Future<String> uploadAvatar({
    required String userId,
    required ProcessedAvatarImage image,
  }) async {
    try {
      final ref = avatarRef(userId);
      await ref.putData(
        Uint8List.fromList(image.bytes),
        SettableMetadata(
          contentType: image.contentType,
          cacheControl: 'public,max-age=3600',
        ),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (error) {
      throw AvatarUploadException(
        error.message ?? 'Échec de l’upload de l’avatar.',
      );
    } catch (error) {
      throw AvatarUploadException('Échec de l’upload de l’avatar : $error');
    }
  }

  Future<void> deleteByDownloadUrl(String photoUrl) async {
    try {
      await storage.refFromURL(photoUrl).delete();
    } on FirebaseException {
      // ignore missing / foreign objects
    }
  }
}
