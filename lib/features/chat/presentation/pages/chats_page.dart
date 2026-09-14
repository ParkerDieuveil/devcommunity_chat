import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Session requise'),
        ),
      );
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            tooltip: 'Nouveau chat',
            onPressed: () {
              context.push(AppRoutePath.newChatPath);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text('Aucune conversation'),
            );
          }

          return profilesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les profils.\n\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (profiles) {
              return ListView.separated(
                itemCount: chats.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 1);
                },
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  final otherProfile = _findOtherProfile(
                    chat,
                    user.id,
                    profiles,
                  );

                  return _ChatTile(
                    chat: chat,
                    profile: otherProfile,
                    currentUserId: user.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  ProfileEntity? _findOtherProfile(
      ChatEntity chat,
      String currentUserId,
      List<ProfileEntity> profiles,
      ) {
    final otherUserIds = chat.participantIds.where(
          (id) => id != currentUserId,
    );

    for (final userId in otherUserIds) {
      for (final profile in profiles) {
        if (profile.id == userId) {
          return profile;
        }
      }
    }

    return null;
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.profile,
    required this.currentUserId,
  });

  final ChatEntity chat;
  final ProfileEntity? profile;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: profile != null &&
            profile!.photoUrl.trim().isNotEmpty
            ? NetworkImage(profile!.photoUrl)
            : null,
        child: profile == null ||
            profile!.photoUrl.trim().isEmpty
            ? Text(
          _getInitial(displayName),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        chat.lastMessage ?? 'Aucun message',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.push(
          AppRoutePath.chatDetail(chat.chatId),
        );
      },
    );
  }

  String _getDisplayName() {
    if (profile != null) {
      final name = profile!.displayname.trim();

      if (name.isNotEmpty) {
        return name;
      }

      final email = profile!.email.trim();

      if (email.isNotEmpty) {
        return email;
      }
    }

    return 'Utilisateur';
  }

  String _getInitial(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }
}