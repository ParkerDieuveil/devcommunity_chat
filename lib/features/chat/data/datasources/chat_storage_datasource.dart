import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/chat_media_image.dart';
import '../../domain/exceptions/chat_media_exceptions.dart';

class ChatStorageDatasource {
  final FirebaseStorage storage;

  ChatStorageDatasource(this.storage);

  Future<String> uploadImage({
    required String chatId,
    required String senderId,
    required ProcessedChatImage image,
  }) async {
    try {
      final fileName =
          '${senderId}_${DateTime.now().microsecondsSinceEpoch}.${image.fileExtension}';
      final ref = storage
          .ref()
          .child('chats')
          .child(chatId)
          .child('images')
          .child(fileName);

      await ref.putData(
        Uint8List.fromList(image.bytes),
        SettableMetadata(
          contentType: image.contentType,
          cacheControl: 'public,max-age=3600',
          customMetadata: {
            'senderId': senderId,
          },
        ),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (error) {
      throw ChatMediaUploadException(
        error.message ?? 'Échec de l’upload de l’image.',
      );
    } catch (error) {
      throw ChatMediaUploadException('Échec de l’upload de l’image : $error');
    }
  }
}
