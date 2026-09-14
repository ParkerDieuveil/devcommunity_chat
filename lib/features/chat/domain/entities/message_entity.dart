enum MessageType { text, image, audio }

class MessageEntity {
  final String messageId;
  final String chatId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;
  final MessageType type;
  final DateTime timestamp;
  final DateTime? readAt;

  const MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.text,
    this.imageUrl,
    this.audioUrl,
    required this.type,
    required this.timestamp,
    this.readAt,
  });

  bool get isRead => readAt != null;
}
