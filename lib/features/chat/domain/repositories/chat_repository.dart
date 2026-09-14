import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> watchUserChats(String userId);

  Stream<List<MessageEntity>> watchMessages(String chatId);
  Future<ChatEntity?> getChat(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  });
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  });
  Future<String> createChat(List<String> participantIds);
}
