import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/datasources/chat_remote_data_source.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
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
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    try {
      return remoteDataSource.watchMessages(chatId).handleError((error, stack) {
        throw _wrap(error, 'Impossible de charger les messages.');
      });
    } catch (error) {
      throw _wrap(error, 'Impossible de charger les messages.');
    }
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
        imageUrl: imageUrl,
      );
    } catch (error) {
      throw _wrap(error, 'Impossible d’envoyer le message.');
    }
  }

  @override
  Future<String> createChat(List<String> participantIds) async {
    try {
      return await remoteDataSource.createChat(participantIds);
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
