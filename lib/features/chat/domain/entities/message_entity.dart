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

  /// Lecteurs du message (`userId` → moment de lecture).
  final Map<String, DateTime> readBy;

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
    this.readBy = const {},
  });

  /// IDs des personnes (hors expéditeur) qui ont vu le message.
  List<String> seenByOtherIds() =>
      readBy.keys.where((id) => id != senderId).toList(growable: false);

  /// Au moins une autre personne a lu (ou ancien champ `readAt`).
  bool get isRead => seenByOtherIds().isNotEmpty || readAt != null;
}
