# Providers Chat

Terminologie : "conversation" (ticket) = `ChatEntity` / `userChatsProvider`.

## Streams UI

| Provider | Type | Expose | Dépend de |
|----------|------|--------|-----------|
| `userChatsProvider(userId)` | `StreamProvider.family<List<ChatEntity>, String>` | liste des chats du user | `watchUserChatsUseCaseProvider` |
| `chatMessagesProvider(chatId)` | `StreamProvider.family<List<MessageEntity>, String>` | messages du chat | `watchMessagesUseCaseProvider` |

```dart
final chats = ref.watch(userChatsProvider(uid));
final messages = ref.watch(chatMessagesProvider(chatId));
```

Gérer `loading` / `data` / `error` via `AsyncValue.when`.

## Actions

| Provider | Type | Usage |
|----------|------|--------|
| `createChatUseCaseProvider` | `Provider<CreateChatUseCase>` | `ref.read(...).call(participantIds)` |
| `sendMessageUseCaseProvider` | `Provider<SendMessageUseCase>` | `ref.read(...).call(chatId:, senderId:, text:)` |
| `syncUserProfileUseCaseProvider` | `Provider<SyncUserProfileUseCase>` | appelé depuis auth après login/register |

## Infra (interne)

`firestoreProvider`, datasources, repositories, autres use cases : pas d'appel Firestore depuis les widgets.
