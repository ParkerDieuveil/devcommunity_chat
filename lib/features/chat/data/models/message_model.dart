import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatId,
    required super.senderId,
    super.text,
    super.imageUrl,
    required super.type,
    required super.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final chatId = doc.reference.parent.parent?.id ?? '';

    final typeRaw = data['type'] as String? ?? 'text';
    final type = typeRaw == MessageType.image.name
        ? MessageType.image
        : MessageType.text;

    return MessageModel(
      messageId: doc.id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      type: type,
      // serverTimestamp encore null sur le 1er snapshot local.
      timestamp: _readDateTime(data['timestamp']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
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
