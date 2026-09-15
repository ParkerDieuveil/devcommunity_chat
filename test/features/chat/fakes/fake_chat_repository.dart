import 'dart:async';

import 'package:devcommunitychat/features/chat/domain/entities/chat_entity.dart';
import 'package:devcommunitychat/features/chat/domain/entities/message_entity.dart';
import 'package:devcommunitychat/features/chat/domain/repositories/chat_repository.dart';

class SentMessage {
  final String chatId;
  final String senderId;
  final String? text;
  final String? imageUrl;

  SentMessage({
    required this.chatId,
    required this.senderId,
    this.text,
    this.imageUrl,
  });
}

/// Fake en mémoire de [ChatRepository], utilisé pour tester l'envoi de
/// messages et la réception temps réel sans dépendre de Firestore.
class FakeChatRepository implements ChatRepository {
  final _chatsController =
  StreamController<List<ChatEntity>>.broadcast();

  final _messagesController =
  StreamController<List<MessageEntity>>.broadcast();

  /// Liste locale des conversations utilisées par les tests.
  final List<ChatEntity> _chats = [];

  final List<SentMessage> sentMessages = [];

  Exception? sendMessageError;

  String createChatResult = 'fake-chat-id';

  void emitChats(List<ChatEntity> chats) {
    _chats
      ..clear()
      ..addAll(chats);

    _chatsController.add(chats);
  }

  void emitMessages(List<MessageEntity> messages) {
    _messagesController.add(messages);
  }

  void dispose() {
    _chatsController.close();
    _messagesController.close();
  }

  @override
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    return _chatsController.stream;
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return _messagesController.stream;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    if (sendMessageError != null) {
      throw sendMessageError!;
    }

    sentMessages.add(
      SentMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  Future<String> createChat(
      List<String> participantIds,
      ) async {
    return createChatResult;
  }

  @override
  Future<ChatEntity?> getChat(
      String chatId,
      ) async {
    for (final chat in _chats) {
      if (chat.chatId == chatId) {
        return chat;
      }
    }

    return null;
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    // Dans le fake, aucune opération Firestore n'est nécessaire.
    // Cette méthode existe uniquement pour respecter le contrat
    // de ChatRepository utilisé par les tests.
  }
}