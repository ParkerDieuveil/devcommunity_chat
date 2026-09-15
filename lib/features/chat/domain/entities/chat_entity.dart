class ChatEntity {
  final String chatId;
  final List<String> participantIds;
  final String? name;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ChatEntity({
    required this.chatId,
    required this.participantIds,
    this.name,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.createdAt,
  });
}
