enum MessageType { text, image }

class MessageEntity {
  final String messageId;
  final String chatId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final MessageType type;
  final DateTime timestamp;

  const MessageEntity({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.type,
    required this.timestamp,
  });
}
