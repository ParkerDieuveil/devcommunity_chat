import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../domain/entities/chat_media_image.dart';
import '../../domain/exceptions/chat_media_exceptions.dart';
import '../../domain/services/chat_media_image_source.dart';

class GalleryChatMediaImageSource implements ChatMediaImageSource {
  final ImagePicker _picker;

  GalleryChatMediaImageSource({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  @override
  Future<RawChatImage?> pick(ChatMediaPickSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == ChatMediaPickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 92,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final mime = lookupMimeType(file.path, headerBytes: bytes) ??
          file.mimeType ??
          'image/jpeg';

      return RawChatImage(
        bytes: bytes,
        mimeType: mime,
        fileName: file.name,
      );
    } catch (error) {
      throw ChatMediaValidationException(
        'Impossible d’ouvrir l’image : $error',
      );
    }
  }
}
