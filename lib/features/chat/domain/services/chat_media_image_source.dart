import '../entities/chat_media_image.dart';

abstract interface class ChatMediaImageSource {
  Future<RawChatImage?> pick(ChatMediaPickSource source);
}
