import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.messageId,
    required super.chatId,
    required super.senderId,
    super.text,
    super.imageUrl,
    super.audioUrl,
    required super.type,
    required super.timestamp,
    super.readAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final chatId = doc.reference.parent.parent?.id ?? '';

    final typeRaw = data['type'] as String? ?? 'text';
    final type = switch (typeRaw) {
      'image' => MessageType.image,
      'audio' => MessageType.audio,
      _ => MessageType.text,
    };

    return MessageModel(
      messageId: doc.id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      audioUrl: data['audioUrl'] as String?,
      type: type,
      timestamp: _readDateTime(data['timestamp']) ?? DateTime.now(),
      readAt: _readDateTime(data['readAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
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
