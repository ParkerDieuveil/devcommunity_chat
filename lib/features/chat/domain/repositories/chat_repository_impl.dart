import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/chat_remote_data_source.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
import '../entities/messages_page.dart';
import '../exceptions/chat_exceptions.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    try {
      return remoteDataSource.watchUserChats(userId).handleError((error, stack) {
        throw _wrap(error, 'Impossible de charger les conversations.');
      });
    } catch (error) {
      throw _wrap(error, 'Impossible de charger les conversations.');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) {
    return remoteDataSource.markMessagesAsRead(
      chatId: chatId,
      userId: userId,
    );
  }

  @override
  Stream<List<MessageEntity>> watchMessages(
    String chatId, {
    int limit = kMessagePageSize,
  }) {
    try {
      return remoteDataSource
          .watchMessages(chatId, limit: limit)
          .handleError((error, stack) {
        throw _wrap(error, 'Impossible de charger les messages.');
      });
    } catch (error) {
      throw _wrap(error, 'Impossible de charger les messages.');
    }
  }

  @override
  Future<MessagesPage> fetchOlderMessages({
    required String chatId,
    required String beforeMessageId,
    int limit = kMessagePageSize,
  }) async {
    try {
      return await remoteDataSource.fetchOlderMessages(
        chatId: chatId,
        beforeMessageId: beforeMessageId,
        limit: limit,
      );
    } catch (error) {
      throw _wrap(error, 'Impossible de charger les messages précédents.');
    }
  }

  @override
  Future<ChatEntity?> getChat(String chatId) {
    return remoteDataSource.getChat(chatId);
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
      );
    } catch (error) {
      throw _wrap(error, 'Impossible d’envoyer le message.');
    }
  }

  @override
  Future<String> createChat(
    List<String> participantIds, {
    String? name,
  }) async {
    try {
      return await remoteDataSource.createChat(
        participantIds,
        name: name,
      );
    } catch (error) {
      throw _wrap(error, 'Impossible de créer la conversation.');
    }
  }

  Never _wrap(Object error, String fallbackMessage) {
    if (error is ChatRepositoryException) {
      throw error;
    }

    if (error is FirebaseException) {
      throw ChatRepositoryException(
        error.message ?? fallbackMessage,
        cause: error,
      );
    }

    throw ChatRepositoryException(fallbackMessage, cause: error);
  }
}
