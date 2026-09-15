import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/entities/chat_media_image.dart';
import '../../domain/exceptions/chat_media_exceptions.dart';
import '../../domain/services/chat_media_image_processor.dart';
import '../../domain/services/chat_media_validator.dart';

class JpegChatMediaImageProcessor implements ChatMediaImageProcessor {
  const JpegChatMediaImageProcessor();

  @override
  Future<ProcessedChatImage> process(RawChatImage raw) async {
    try {
      final decoded = img.decodeImage(Uint8List.fromList(raw.bytes));
      if (decoded == null) {
        throw const ChatMediaProcessingException(
          'Impossible de lire cette image.',
        );
      }

      var frame = img.bakeOrientation(decoded);
      final maxSide = ChatMediaConstraints.maxDimensionPx;
      if (frame.width > maxSide || frame.height > maxSide) {
        if (frame.width >= frame.height) {
          frame = img.copyResize(
            frame,
            width: maxSide,
            interpolation: img.Interpolation.average,
          );
        } else {
          frame = img.copyResize(
            frame,
            height: maxSide,
            interpolation: img.Interpolation.average,
          );
        }
      }

      var quality = ChatMediaConstraints.jpegQuality;
      var encoded = img.encodeJpg(frame, quality: quality);
      while (encoded.length > ChatMediaConstraints.maxProcessedBytes &&
          quality > 40) {
        quality -= 10;
        encoded = img.encodeJpg(frame, quality: quality);
      }

      return ProcessedChatImage(bytes: encoded);
    } on ChatMediaException {
      rethrow;
    } catch (error) {
      throw ChatMediaProcessingException(
        'Échec du traitement de l’image : $error',
      );
    }
  }
}
