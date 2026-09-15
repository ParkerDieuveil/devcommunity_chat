import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
import '../entities/messages_page.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> watchUserChats(String userId);

  Stream<List<MessageEntity>> watchMessages(
    String chatId, {
    int limit = kMessagePageSize,
  });

  Future<MessagesPage> fetchOlderMessages({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  });

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

  Future<String> createChat(
    List<String> participantIds, {
    String? name,
  });
}
