import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/chat_entity.dart';
import 'chat_display.dart';

/// Résultat d'une recherche type messagerie (discussions + contacts).
class ChatSearchResult {
  const ChatSearchResult({
    required this.conversations,
    required this.contacts,
  });

  final List<ChatEntity> conversations;
  final List<ProfileEntity> contacts;

  bool get isEmpty => conversations.isEmpty && contacts.isEmpty;
}

bool looksLikeEmail(String query) => query.contains('@');

bool matchesProfile(ProfileEntity profile, String query) {
  final q = query.toLowerCase();
  return profile.displayname.toLowerCase().contains(q) ||
      profile.email.toLowerCase().contains(q);
}

/// Partenaires déjà en discussion 1-1 avec [userId].
Set<String> oneToOnePartnerIds(List<ChatEntity> chats, String userId) {
  return {
    for (final chat in chats)
      if (chat.participantIds.length == 2)
        for (final id in chat.participantIds)
          if (id != userId) id,
  };
}

ChatSearchResult searchChatsAndContacts({
  required List<ChatEntity> chats,
  required List<ProfileEntity> profiles,
  required String userId,
  required String query,
  required String userFallback,
  required String groupFallback,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return const ChatSearchResult(conversations: [], contacts: []);
  }

  final conversations = chats.where((chat) {
    final others = findOtherProfiles(
      participantIds: chat.participantIds,
      currentUserId: userId,
      profiles: profiles,
    );
    final title = chatDisplayTitle(
      others,
      chatName: chat.name,
      emptyFallback:
          chat.participantIds.length > 2 ? groupFallback : userFallback,
      multiFallback: groupFallback,
    ).toLowerCase();
    final last = (chat.lastMessage ?? '').toLowerCase();
    return title.contains(q) || last.contains(q);
  }).toList();

  final alreadyChatting = oneToOnePartnerIds(chats, userId);
  final contacts = profiles
      .where((p) => p.id != userId)
      .where((p) => !alreadyChatting.contains(p.id))
      .where((p) => matchesProfile(p, q))
      .toList();

  return ChatSearchResult(
    conversations: conversations,
    contacts: contacts,
  );
}

/// Somme des non-lus (1-1 ou groupes selon [groupsOnly]).
int unreadTotal(
  List<ChatEntity> chats,
  String userId, {
  required bool groupsOnly,
}) {
  return chats
      .where(
        (c) => groupsOnly
            ? c.participantIds.length > 2
            : c.participantIds.length <= 2,
      )
      .fold<int>(0, (sum, c) => sum + c.unreadFor(userId));
}
