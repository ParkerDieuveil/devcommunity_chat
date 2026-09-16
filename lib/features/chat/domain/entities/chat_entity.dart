class ChatEntity {
  final String chatId;
  final List<String> participantIds;
  final String? name;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  /// Compteur non-lus par utilisateur (`userId` → nombre).
  final Map<String, int> unreadCounts;

  const ChatEntity({
    required this.chatId,
    required this.participantIds,
    this.name,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.createdAt,
    this.unreadCounts = const {},
  });

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;
}
