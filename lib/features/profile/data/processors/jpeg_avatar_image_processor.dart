import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/entities/avatar_image.dart';
import '../../domain/exceptions/profile_exceptions.dart';
import '../../domain/services/avatar_image_processor.dart';
import '../../domain/services/avatar_validator.dart';

class JpegAvatarImageProcessor implements AvatarImageProcessor {
  const JpegAvatarImageProcessor();

  @override
  Future<ProcessedAvatarImage> process(RawAvatarImage raw) async {
    try {
      final decoded = img.decodeImage(Uint8List.fromList(raw.bytes));
      if (decoded == null) {
        throw const AvatarProcessingException(
          'Impossible de lire cette image.',
        );
      }

      var frame = img.bakeOrientation(decoded);
      final maxSide = AvatarConstraints.maxDimensionPx;
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

      var quality = AvatarConstraints.jpegQuality;
      List<int> encoded = img.encodeJpg(frame, quality: quality);

      while (encoded.length > AvatarConstraints.maxProcessedBytes &&
          quality > 40) {
        quality -= 10;
        encoded = img.encodeJpg(frame, quality: quality);
      }

      return ProcessedAvatarImage(bytes: encoded);
    } on ProfileException {
      rethrow;
    } catch (error) {
      throw AvatarProcessingException(
        'Échec du traitement de l’image : $error',
      );
    }
  }
}
