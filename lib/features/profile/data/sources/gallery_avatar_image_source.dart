import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../domain/entities/avatar_image.dart';
import '../../domain/exceptions/profile_exceptions.dart';
import '../../domain/services/avatar_image_source.dart';

class GalleryAvatarImageSource implements AvatarImageSource {
  final ImagePicker _picker;

  GalleryAvatarImageSource({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  @override
  Future<RawAvatarImage?> pick(AvatarPickSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == AvatarPickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final mime = lookupMimeType(file.path, headerBytes: bytes) ??
          file.mimeType ??
          'image/jpeg';

      return RawAvatarImage(
        bytes: bytes,
        mimeType: mime,
        fileName: file.name,
      );
    } catch (error) {
      throw AvatarValidationException(
        'Impossible d’ouvrir l’image : $error',
      );
    }
  }
}
