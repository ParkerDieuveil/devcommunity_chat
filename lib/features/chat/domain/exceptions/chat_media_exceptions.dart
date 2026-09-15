sealed class ChatMediaException implements Exception {
  final String message;

  const ChatMediaException(this.message);

  @override
  String toString() => message;
}

final class ChatMediaSelectionCancelled extends ChatMediaException {
  const ChatMediaSelectionCancelled() : super('Sélection d’image annulée.');
}

final class ChatMediaValidationException extends ChatMediaException {
  const ChatMediaValidationException(super.message);
}

final class ChatMediaProcessingException extends ChatMediaException {
  const ChatMediaProcessingException(super.message);
}

final class ChatMediaUploadException extends ChatMediaException {
  const ChatMediaUploadException(super.message);
}
