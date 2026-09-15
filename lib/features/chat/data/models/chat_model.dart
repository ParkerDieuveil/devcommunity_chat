import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.chatId,
    required super.participantIds,
    super.name,
    super.lastMessage,
    super.lastMessageSenderId,
    super.lastMessageAt,
    required super.createdAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ChatModel(
      chatId: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      name: data['name'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageAt: _readDateTime(data['lastMessageAt']),
      createdAt: _readDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      if (name != null) 'name': name,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
