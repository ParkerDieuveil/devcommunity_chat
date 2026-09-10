import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> watchUserChats(String userId);

  Stream<List<MessageModel>> watchMessages(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  });

  Future<String> createChat(List<String> participantIds);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _chats =>
      firestore.collection('chats');

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _chats
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    final isImage = imageUrl != null && imageUrl.isNotEmpty;
    final type = isImage ? 'image' : 'text';
    final preview = isImage ? (text?.isNotEmpty == true ? text! : '[image]') : (text ?? '');

    // Message + preview du chat dans le même batch.
    final batch = firestore.batch();
    final messageRef = _chats.doc(chatId).collection('messages').doc();

    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(_chats.doc(chatId), {
      'lastMessage': preview,
      'lastMessageSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<String> createChat(List<String> participantIds) async {
    // isEqualTo sur un array = égalité stricte (ordre inclus).
    final sortedIds = [...participantIds]..sort();

    final existing = await _chats
        .where('participantIds', isEqualTo: sortedIds)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final docRef = _chats.doc();
    // Sans lastMessageAt, le doc sort mal / disparaît du orderBy ci-dessus.
    await docRef.set({
      'participantIds': sortedIds,
      'lastMessage': null,
      'lastMessageSenderId': null,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
