import '../entities/message_entity.dart';

/// Résultat d'une page de messages (lazy loading).
class MessagesPage {
  const MessagesPage({
    required this.messages,
    required this.hasMore,
  });

  /// Messages triés du plus ancien au plus récent.
  final List<MessageEntity> messages;

  /// `true` s'il reste potentiellement des messages plus anciens.
  final bool hasMore;
}

/// Taille de page : derniers N messages à l'ouverture, puis +N au scroll.
const int kMessagePageSize = 10;
