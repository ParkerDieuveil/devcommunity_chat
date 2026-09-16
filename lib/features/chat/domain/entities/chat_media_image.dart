enum ChatMediaPickSource { gallery, camera }

class RawChatImage {
  final List<int> bytes;
  final String? mimeType;
  final String? fileName;

  const RawChatImage({
    required this.bytes,
    this.mimeType,
    this.fileName,
  });

  int get sizeInBytes => bytes.length;
}

class ProcessedChatImage {
  final List<int> bytes;
  final String contentType;
  final String fileExtension;

  const ProcessedChatImage({
    required this.bytes,
    this.contentType = 'image/jpeg',
    this.fileExtension = 'jpg',
  });

  int get sizeInBytes => bytes.length;
}
