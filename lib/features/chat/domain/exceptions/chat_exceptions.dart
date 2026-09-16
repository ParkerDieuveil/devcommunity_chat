/// Erreur chat exposée à l'UI (pas de FirebaseException brute).
class ChatRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const ChatRepositoryException(this.message, {this.cause});

  @override
  String toString() => 'ChatRepositoryException: $message';
}
