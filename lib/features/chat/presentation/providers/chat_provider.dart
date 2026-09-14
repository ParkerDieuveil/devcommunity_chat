import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/chat_storage_datasource.dart';
import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../data/processors/jpeg_chat_media_processor.dart';
import '../../data/repositories/chat_media_storage_impl.dart';
import '../../data/sources/gallery_chat_media_image_source.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_media_storage.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/chat_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/user_profile_repository_impl.dart';
import '../../domain/services/chat_media_image_processor.dart';
import '../../domain/services/chat_media_image_source.dart';
import '../../domain/services/chat_media_validator.dart';
import '../../domain/usecases/create_chat_use_case.dart';
import '../../domain/usecases/get_chat_use_case.dart';
import '../../domain/usecases/mark_messages_as_read_use_case.dart';
import '../../domain/usecases/send_chat_image_use_case.dart';
import '../../domain/usecases/send_message_use_case.dart';
import '../../domain/usecases/sync_user_profile_use_case.dart';
import '../../domain/usecases/watch_messages_use_case.dart';
import '../../domain/usecases/watch_user_chats_use_case.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

final chatStorageDatasourceProvider = Provider<ChatStorageDatasource>((ref) {
  return ChatStorageDatasource(ref.watch(firebaseStorageProvider));
});

final getChatUseCaseProvider = Provider<GetChatUseCase>((ref) {
  return GetChatUseCase(
    ref.watch(chatRepositoryProvider),
  );
});

final chatByIdProvider =
    FutureProvider.family<ChatEntity?, String>((ref, chatId) {
  return ref.watch(getChatUseCaseProvider).call(chatId);
});

final markMessagesAsReadUseCaseProvider =
    Provider<MarkMessagesAsReadUseCase>((ref) {
  return MarkMessagesAsReadUseCase(
    ref.watch(chatRepositoryProvider),
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

final chatMediaStorageProvider = Provider<ChatMediaStorage>((ref) {
  return ChatMediaStorageImpl(ref.watch(chatStorageDatasourceProvider));
});

final chatMediaImageSourceProvider = Provider<ChatMediaImageSource>((ref) {
  return GalleryChatMediaImageSource();
});

final chatMediaImageProcessorProvider = Provider<ChatMediaImageProcessor>((
  ref,
) {
  return const JpegChatMediaImageProcessor();
});

final chatMediaValidatorProvider = Provider<ChatMediaValidator>((ref) {
  return const ChatMediaValidator();
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

final sendChatImageUseCaseProvider = Provider<SendChatImageUseCase>((ref) {
  return SendChatImageUseCase(
    imageSource: ref.watch(chatMediaImageSourceProvider),
    validator: ref.watch(chatMediaValidatorProvider),
    processor: ref.watch(chatMediaImageProcessorProvider),
    mediaStorage: ref.watch(chatMediaStorageProvider),
    chatRepository: ref.watch(chatRepositoryProvider),
  );
});

final createChatUseCaseProvider = Provider<CreateChatUseCase>((ref) {
  return CreateChatUseCase(ref.watch(chatRepositoryProvider));
});

final syncUserProfileUseCaseProvider = Provider<SyncUserProfileUseCase>((ref) {
  return SyncUserProfileUseCase(ref.watch(userProfileRepositoryProvider));
});

final userChatsProvider =
    StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  return ref.watch(watchUserChatsUseCaseProvider).call(userId);
});

final chatMessagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  return ref.watch(watchMessagesUseCaseProvider).call(chatId);
});
