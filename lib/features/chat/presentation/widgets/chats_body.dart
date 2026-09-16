import 'package:flutter/material.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/chat_entity.dart';
import '../utils/chat_search.dart';
import 'chat_list_tile.dart';
import 'invite_not_registered_card.dart';
import 'list_section_label.dart';
import 'user_contact_tile.dart';

/// Résultats de recherche : discussions, contacts, ou invite.
class ChatsSearchResults extends StatelessWidget {
  const ChatsSearchResults({
    super.key,
    required this.result,
    required this.profiles,
    required this.userId,
    required this.query,
    required this.strings,
    required this.creatingChatFor,
    required this.onOpenContact,
  });

  final ChatSearchResult result;
  final List<ProfileEntity> profiles;
  final String userId;
  final String query;
  final AppStrings strings;
  final String? creatingChatFor;
  final ValueChanged<String> onOpenContact;

  @override
  Widget build(BuildContext context) {
    if (result.isEmpty) {
      if (looksLikeEmail(query)) {
        return InviteNotRegisteredCard(query: query, strings: strings);
      }
      return Center(child: Text(strings.noChatsFound));
    }

    return ListView(
      children: [
        if (result.conversations.isNotEmpty) ...[
          ListSectionLabel(strings.conversationsSection),
          for (final chat in result.conversations)
            ChatListTile.fromData(
              chat: chat,
              profiles: profiles,
              currentUserId: userId,
              strings: strings,
            ),
        ],
        if (result.contacts.isNotEmpty) ...[
          ListSectionLabel(strings.contactsSection),
          for (final profile in result.contacts)
            UserContactTile(
              displayName: profile.displayname,
              email: profile.email,
              photoUrl: profile.photoUrl,
              isOnline: profile.isEffectivelyOnline,
              loading: creatingChatFor == profile.id,
              startChatTooltip: strings.startChat,
              onTap: () => onOpenContact(profile.id),
            ),
        ],
      ],
    );
  }
}

/// Liste simple des conversations (hors recherche).
class ChatsConversationList extends StatelessWidget {
  const ChatsConversationList({
    super.key,
    required this.chats,
    required this.profiles,
    required this.userId,
    required this.strings,
  });

  final List<ChatEntity> chats;
  final List<ProfileEntity> profiles;
  final String userId;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatListTile.fromData(
          chat: chats[index],
          profiles: profiles,
          currentUserId: userId,
          strings: strings,
        );
      },
    );
  }
}
