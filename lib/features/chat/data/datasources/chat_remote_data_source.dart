import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/messages_page.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> watchUserChats(String userId);
  Future<ChatModel?> getChat(String chatId);

  Stream<List<MessageModel>> watchMessages(
    String chatId, {
    int limit = kMessagePageSize,
  });

  Future<MessagesPage> fetchOlderMessages({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  });

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  });

  Future<String> createChat(
    List<String> participantIds, {
    String? name,
  });

  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> get _chats =>
      firestore.collection('chats');

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _chats
        .where(
      'participantIds',
      arrayContains: userId,
    )
        .orderBy(
      'lastMessageAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ChatModel.fromFirestore(doc),
      )
          .toList(),
    );
  }

  @override
  Future<ChatModel?> getChat(String chatId) async {
    final doc = await _chats.doc(chatId).get();

    if (!doc.exists) {
      return null;
    }

    return ChatModel.fromFirestore(doc);
  }
  @override
  Stream<List<MessageModel>> watchMessages(
    String chatId, {
    int limit = kMessagePageSize,
  }) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .limitToLast(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<MessagesPage> fetchOlderMessages({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  }) async {
    final messagesRef = _chats.doc(chatId).collection('messages');
    final cursorDoc = await messagesRef.doc(beforeMessageId).get();

    if (!cursorDoc.exists) {
      return const MessagesPage(messages: [], hasMore: false);
    }

    final snapshot = await messagesRef
        .orderBy('timestamp', descending: true)
        .startAfterDocument(cursorDoc)
        .limit(limit)
        .get();

    final messages = snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList()
        .reversed
        .toList();

    return MessagesPage(
      messages: messages,
      hasMore: snapshot.docs.length >= limit,
    );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final isImage = imageUrl != null && imageUrl.isNotEmpty;
    final isAudio = audioUrl != null && audioUrl.isNotEmpty;

    final type = isAudio
        ? 'audio'
        : isImage
            ? 'image'
            : 'text';

    final preview = isAudio
        ? '[audio]'
        : isImage
            ? (text?.isNotEmpty == true ? text! : '[image]')
            : (text ?? '');

    final batch = firestore.batch();

    final messageRef = _chats.doc(chatId).collection('messages').doc();
    final chatRef = _chats.doc(chatId);

    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'readAt': null,
      'readBy': <String, dynamic>{},
    });

    final chatUpdate = <String, dynamic>{
      'lastMessage': preview,
      'lastMessageSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    };

    // Badge non-lus pour les autres participants (style WhatsApp).
    final chatSnap = await chatRef.get();
    final participants = List<String>.from(
      chatSnap.data()?['participantIds'] ?? const [],
    );
    for (final participantId in participants) {
      if (participantId == senderId) continue;
      chatUpdate['unreadCounts.$participantId'] = FieldValue.increment(1);
    }

    batch.update(chatRef, chatUpdate);
    await batch.commit();
  }

  @override
  Future<String> createChat(
    List<String> participantIds, {
    String? name,
  }) async {
    final sortedIds = [...participantIds]..sort();
    final trimmedName = name?.trim();
    final hasName = trimmedName != null && trimmedName.isNotEmpty;

    // 1-1 : réutiliser un chat existant. Groupes nommés : toujours créer.
    if (!hasName) {
      final existing = await _chats
          .where(
            'participantIds',
            isEqualTo: sortedIds,
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    final docRef = _chats.doc();

    await docRef.set({
      'participantIds': sortedIds,
      if (hasName) 'name': trimmedName,
      'lastMessage': null,
      'lastMessageSenderId': null,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'unreadCounts': {
        for (final id in sortedIds) id: 0,
      },
    });

    return docRef.id;
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    // Lazy: seulement les messages récents.
    final snapshot = await _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(kMessagePageSize)
        .get();

    final batch = firestore.batch();
    var updates = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final senderId = data['senderId'] as String?;
      if (senderId == null || senderId == userId) continue;

      final readBy = data['readBy'];
      final alreadyRead = readBy is Map && readBy.containsKey(userId);
      if (alreadyRead) continue;

      batch.update(doc.reference, {
        'readBy.$userId': FieldValue.serverTimestamp(),
        'readAt': FieldValue.serverTimestamp(),
      });
      updates++;
    }

    // Remet le badge à 0 pour cet utilisateur.
    batch.update(_chats.doc(chatId), {
      'unreadCounts.$userId': 0,
    });
    updates++;

    if (updates > 0) {
      await batch.commit();
    }
  }
}