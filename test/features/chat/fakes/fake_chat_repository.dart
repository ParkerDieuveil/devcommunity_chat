import 'dart:async';

import 'package:devcommunitychat/features/chat/domain/entities/chat_entity.dart';
import 'package:devcommunitychat/features/chat/domain/entities/message_entity.dart';
import 'package:devcommunitychat/features/chat/domain/entities/messages_page.dart';
import 'package:devcommunitychat/features/chat/domain/repositories/chat_repository.dart';

class SentMessage {
  final String chatId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final String? audioUrl;

  SentMessage({
    required this.chatId,
    required this.senderId,
    this.text,
    this.imageUrl,
    this.audioUrl,
  });
}

/// Fake en mémoire de [ChatRepository].
class FakeChatRepository implements ChatRepository {
  final _chatsController = StreamController<List<ChatEntity>>.broadcast();
  final _messagesController =
      StreamController<List<MessageEntity>>.broadcast();

  final List<ChatEntity> _chats = [];
  final List<MessageEntity> _allMessages = [];
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
    _allMessages
      ..clear()
      ..addAll(messages);
    _messagesController.add(List<MessageEntity>.from(messages));
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
  Stream<List<MessageEntity>> watchMessages(
    String chatId, {
    int limit = kMessagePageSize,
  }) {
    return _messagesController.stream.map((messages) {
      if (messages.length <= limit) return messages;
      return messages.sublist(messages.length - limit);
    });
  }

  @override
  Future<MessagesPage> fetchOlderMessages({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  }) async {
    final index =
        _allMessages.indexWhere((m) => m.messageId == beforeMessageId);
    if (index <= 0) {
      return const MessagesPage(messages: [], hasMore: false);
    }
    final start = (index - limit).clamp(0, index);
    final page = _allMessages.sublist(start, index);
    return MessagesPage(messages: page, hasMore: start > 0);
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
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
        audioUrl: audioUrl,
      ),
    );
  }

  @override
  Future<String> createChat(
    List<String> participantIds, {
    String? name,
  }) async {
    return createChatResult;
  }

  @override
  Future<ChatEntity?> getChat(String chatId) async {
    for (final chat in _chats) {
      if (chat.chatId == chatId) return chat;
    }
    return null;
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {}
}
