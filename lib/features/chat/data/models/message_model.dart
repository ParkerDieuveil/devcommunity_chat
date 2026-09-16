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
    super.readBy,
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
      readBy: _readReadBy(data['readBy']),
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
      'readBy': {
        for (final entry in readBy.entries)
          entry.key: Timestamp.fromDate(entry.value),
      },
    };
  }

  static Map<String, DateTime> _readReadBy(dynamic value) {
    if (value is! Map) return const {};
    final result = <String, DateTime>{};
    value.forEach((key, raw) {
      final at = _readDateTime(raw);
      if (at != null) result[key.toString()] = at;
    });
    return result;
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
