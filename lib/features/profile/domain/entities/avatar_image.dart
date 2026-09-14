/// Image brute issue du device (galerie / caméra), avant traitement.
class RawAvatarImage {
  final List<int> bytes;
  final String? mimeType;
  final String? fileName;

  const RawAvatarImage({
    required this.bytes,
    this.mimeType,
    this.fileName,
  });

  int get sizeInBytes => bytes.length;
}

/// Image prête pour Storage (JPEG normalisé).
class ProcessedAvatarImage {
  final List<int> bytes;
  final String contentType;
  final String fileExtension;

  const ProcessedAvatarImage({
    required this.bytes,
    this.contentType = 'image/jpeg',
    this.fileExtension = 'jpg',
  });

  int get sizeInBytes => bytes.length;
}
