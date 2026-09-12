/// Entité représentant un message dans l'interface de conversation.
class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final String? senderAvatar;
  final DateTime timestamp;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    this.senderAvatar,
    required this.timestamp,
    required this.isMine,
  });
}