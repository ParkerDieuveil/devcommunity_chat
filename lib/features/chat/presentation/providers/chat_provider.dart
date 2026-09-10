import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/chat_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/user_profile_repository_impl.dart';
import '../../domain/usecases/create_chat_use_case.dart';
import '../../domain/usecases/send_message_use_case.dart';
import '../../domain/usecases/sync_user_profile_use_case.dart';
import '../../domain/usecases/watch_messages_use_case.dart';
import '../../domain/usecases/watch_user_chats_use_case.dart';

/// Infra Firestore (datasources uniquement).
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

final userProfileRemoteDataSourceProvider =
    Provider<UserProfileRemoteDataSource>((ref) {
  return UserProfileRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
  );
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    remoteDataSource: ref.watch(userProfileRemoteDataSourceProvider),
  );
});

final watchUserChatsUseCaseProvider = Provider<WatchUserChatsUseCase>((ref) {
  return WatchUserChatsUseCase(ref.watch(chatRepositoryProvider));
});

final watchMessagesUseCaseProvider = Provider<WatchMessagesUseCase>((ref) {
  return WatchMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final createChatUseCaseProvider = Provider<CreateChatUseCase>((ref) {
  return CreateChatUseCase(ref.watch(chatRepositoryProvider));
});

final syncUserProfileUseCaseProvider = Provider<SyncUserProfileUseCase>((ref) {
  return SyncUserProfileUseCase(ref.watch(userProfileRepositoryProvider));
});

/// Conversations (ChatEntity) du user, temps réel.
/// Usage : `ref.watch(userChatsProvider(uid))`
final userChatsProvider =
    StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  return ref.watch(watchUserChatsUseCaseProvider).call(userId);
});

/// Messages d'un chat, temps réel.
/// Usage : `ref.watch(chatMessagesProvider(chatId))`
final chatMessagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  return ref.watch(watchMessagesUseCaseProvider).call(chatId);
});
