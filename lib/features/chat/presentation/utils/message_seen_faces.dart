import '../../domain/entities/message_entity.dart';
import '../../../profile/domain/entities/profile.dart';

/// Pour chaque lecteur : id du **dernier** message qu'il a vu
/// (messages triés du plus ancien au plus récent).
Map<String, String> lastReadMessageIdByUser(List<MessageEntity> messages) {
  final result = <String, String>{};
  for (final message in messages) {
    for (final readerId in message.seenByOtherIds()) {
      result[readerId] = message.messageId;
    }
  }
  return result;
}

/// Profils à afficher sous [message] (style Messenger).
List<ProfileEntity> seenFacesForMessage({
  required MessageEntity message,
  required Map<String, String> lastReadByUser,
  required List<ProfileEntity> profiles,
}) {
  final ids = <String>[];
  lastReadByUser.forEach((userId, messageId) {
    if (messageId == message.messageId) ids.add(userId);
  });
  if (ids.isEmpty) return const [];

  final byId = {for (final p in profiles) p.id: p};
  return [
    for (final id in ids)
      if (byId[id] != null) byId[id]!,
  ];
}
