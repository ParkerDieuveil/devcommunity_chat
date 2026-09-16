import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/entities/messages_page.dart';
import 'chat_provider.dart';

class ChatMessagesViewState {
  const ChatMessagesViewState({
    required this.messages,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  final List<MessageEntity> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  ChatMessagesViewState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
  }) {
    return ChatMessagesViewState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// State des messages (derniers N + pages plus anciennes).
/// Riverpod 3 : l'argument family passe par le constructeur.
class ChatMessagesController extends Notifier<ChatMessagesViewState> {
  ChatMessagesController(this.chatId);

  final String chatId;

  final _older = <MessageEntity>[];
  var _recent = <MessageEntity>[];
  var _hasMoreOlder = true;
  StreamSubscription<List<MessageEntity>>? _subscription;

  @override
  ChatMessagesViewState build() {
    _older.clear();
    _recent = [];
    _hasMoreOlder = true;

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    _subscription = ref
        .read(watchMessagesUseCaseProvider)
        .call(chatId, limit: kMessagePageSize)
        .listen(
      (recent) {
        _recent = recent;
        if (_older.isEmpty) {
          _hasMoreOlder = recent.length >= kMessagePageSize;
        }
        state = ChatMessagesViewState(
          messages: _merge(_older, _recent),
          isLoading: false,
          isLoadingMore: false,
          hasMore: _hasMoreOlder,
        );
      },
      onError: (Object error, StackTrace _) {
        state = ChatMessagesViewState(
          messages: _merge(_older, _recent),
          isLoading: false,
          isLoadingMore: false,
          hasMore: _hasMoreOlder,
          error: error,
        );
      },
    );

    return const ChatMessagesViewState(
      messages: [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !_hasMoreOlder || state.messages.isEmpty) {
      return;
    }

    final oldestId = state.messages.first.messageId;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await ref.read(fetchOlderMessagesUseCaseProvider).call(
            chatId: chatId,
            beforeMessageId: oldestId,
          );

      final existingIds = {
        for (final message in _older) message.messageId,
        for (final message in _recent) message.messageId,
      };

      final fresh = page.messages
          .where((message) => existingIds.add(message.messageId))
          .toList();

      _older.insertAll(0, fresh);
      _hasMoreOlder = page.hasMore;

      state = ChatMessagesViewState(
        messages: _merge(_older, _recent),
        isLoading: false,
        isLoadingMore: false,
        hasMore: _hasMoreOlder,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }

  static List<MessageEntity> _merge(
    List<MessageEntity> older,
    List<MessageEntity> recent,
  ) {
    final byId = <String, MessageEntity>{};
    for (final message in older) {
      byId[message.messageId] = message;
    }
    for (final message in recent) {
      byId[message.messageId] = message;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return merged;
  }
}

final chatMessagesControllerProvider = NotifierProvider.family<
    ChatMessagesController, ChatMessagesViewState, String>(
  ChatMessagesController.new,
);
