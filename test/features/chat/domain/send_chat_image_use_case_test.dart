import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/chat/domain/entities/chat_media_image.dart';
import 'package:devcommunitychat/features/chat/domain/exceptions/chat_media_exceptions.dart';
import 'package:devcommunitychat/features/chat/domain/repositories/chat_media_storage.dart';
import 'package:devcommunitychat/features/chat/domain/services/chat_media_image_processor.dart';
import 'package:devcommunitychat/features/chat/domain/services/chat_media_image_source.dart';
import 'package:devcommunitychat/features/chat/domain/services/chat_media_validator.dart';
import 'package:devcommunitychat/features/chat/domain/usecases/send_chat_image_use_case.dart';

import '../fakes/fake_chat_repository.dart';

class _FakeSource implements ChatMediaImageSource {
  RawChatImage? image;

  _FakeSource(this.image);

  @override
  Future<RawChatImage?> pick(ChatMediaPickSource source) async => image;
}

class _FakeProcessor implements ChatMediaImageProcessor {
  @override
  Future<ProcessedChatImage> process(RawChatImage raw) async {
    return ProcessedChatImage(bytes: raw.bytes);
  }
}

class _FakeStorage implements ChatMediaStorage {
  String? lastChatId;
  String? lastSenderId;

  @override
  Future<String> uploadImage({
    required String chatId,
    required String senderId,
    required ProcessedChatImage image,
  }) async {
    lastChatId = chatId;
    lastSenderId = senderId;
    return 'https://cdn.example/chats/$chatId/images/1.jpg';
  }
}

void main() {
  group('ChatMediaValidator', () {
    const validator = ChatMediaValidator();

    test('rejette un fichier vide', () {
      expect(
        () => validator.validateRaw(const RawChatImage(bytes: [])),
        throwsA(isA<ChatMediaValidationException>()),
      );
    });
  });

  group('SendChatImageUseCase', () {
    test('annulation → false sans envoi', () async {
      final chatRepo = FakeChatRepository();
      final storage = _FakeStorage();
      final useCase = SendChatImageUseCase(
        imageSource: _FakeSource(null),
        validator: const ChatMediaValidator(),
        processor: _FakeProcessor(),
        mediaStorage: storage,
        chatRepository: chatRepo,
      );

      final sent = await useCase.call(
        chatId: 'c1',
        senderId: 'u1',
        source: ChatMediaPickSource.gallery,
      );

      expect(sent, isFalse);
      expect(storage.lastChatId, isNull);
      expect(chatRepo.sentMessages, isEmpty);
    });

    test('galerie → upload + sendMessage image + légende', () async {
      final chatRepo = FakeChatRepository();
      final storage = _FakeStorage();
      final useCase = SendChatImageUseCase(
        imageSource: _FakeSource(
          RawChatImage(bytes: List.filled(32, 1), mimeType: 'image/jpeg'),
        ),
        validator: const ChatMediaValidator(),
        processor: _FakeProcessor(),
        mediaStorage: storage,
        chatRepository: chatRepo,
      );

      final sent = await useCase.call(
        chatId: 'c1',
        senderId: 'u1',
        source: ChatMediaPickSource.gallery,
        caption: 'Regarde ça',
      );

      expect(sent, isTrue);
      expect(storage.lastChatId, 'c1');
      expect(storage.lastSenderId, 'u1');
      expect(chatRepo.sentMessages, hasLength(1));
      expect(chatRepo.sentMessages.single.imageUrl, contains('images/1.jpg'));
      expect(chatRepo.sentMessages.single.text, 'Regarde ça');
    });
  });
}
