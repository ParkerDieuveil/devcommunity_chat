import '../entities/chat_media_image.dart';

abstract interface class ChatMediaImageProcessor {
  Future<ProcessedChatImage> process(RawChatImage raw);
}
