import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/utils/date_format.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';

const _headerBlue = Color(0xFF1565C0);
const _accentBlue = Color(0xFF03A9F4);

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ConsumerState<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  var _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddMenu() async {
    final s = ref.read(appStringsProvider);
    final action = await showDialog<_AddMenuAction>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/logo/User Plus.svg',
                    width: 24,
                    height: 24,
                  ),
                  title: Text(
                    s.addContact,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () =>
                      Navigator.pop(dialogContext, _AddMenuAction.addFriend),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.groups_outlined,
                    color: Color(0xFF616161),
                  ),
                  title: Text(
                    s.createGroup,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () =>
                      Navigator.pop(dialogContext, _AddMenuAction.createGroup),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _AddMenuAction.addFriend:
        context.push(AppRoutePath.newChatPath);
      case _AddMenuAction.createGroup:
        context.push(AppRoutePath.createGroupPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(appStringsProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(s.sessionRequired)));
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));
    final profilesAsync = ref.watch(profilesProvider);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _ChatsHeader(
            searching: _searching,
            searchController: _searchController,
            searchHint: s.search,
            searchTooltip: s.search,
            addTooltip: s.add,
            onToggleSearch: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) _searchController.clear();
              });
            },
            onSearchChanged: () => setState(() {}),
            onAdd: _openAddMenu,
          ),
          Expanded(
            child: chatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
              data: (chats) {
                if (chats.isEmpty) {
                  return _EmptyChatsState(
                    title: s.emptyChatsTitle,
                    subtitle: s.emptyChatsSubtitle,
                    buttonLabel: s.newChat,
                    onStartChat: _openAddMenu,
                  );
                }

                return profilesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (profiles) {
                    final filtered = chats.where((chat) {
                      if (query.isEmpty) return true;
                      final other = _findOtherProfiles(chat, user.id, profiles);
                      final name = _chatTitle(
                        chat,
                        other,
                        userFallback: s.userFallback,
                        groupFallback: s.groupFallback,
                      ).toLowerCase();
                      final last = (chat.lastMessage ?? '').toLowerCase();
                      return name.contains(query) || last.contains(query);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(s.noChatsFound),
                      );
                    }

                    // Pas de Divider : le Figma sépare les lignes par l'espace seul.
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final chat = filtered[index];
                        final others = _findOtherProfiles(
                          chat,
                          user.id,
                          profiles,
                        );
                        return _ChatTile(
                          chat: chat,
                          others: others,
                          userFallback: s.userFallback,
                          groupFallback: s.groupFallback,
                          noMessagePreview: s.noMessagePreview,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ProfileEntity> _findOtherProfiles(
    ChatEntity chat,
    String currentUserId,
    List<ProfileEntity> profiles,
  ) {
    final result = <ProfileEntity>[];
    for (final userId in chat.participantIds) {
      if (userId == currentUserId) continue;
      for (final profile in profiles) {
        if (profile.id == userId) {
          result.add(profile);
          break;
        }
      }
    }
    return result;
  }
}

String _chatTitle(
  ChatEntity chat,
  List<ProfileEntity> others, {
  required String userFallback,
  required String groupFallback,
}) {
  if (others.isEmpty) {
    return chat.participantIds.length > 2 ? groupFallback : userFallback;
  }
  if (others.length == 1) {
    final name = others.first.displayname.trim();
    if (name.isNotEmpty) return name;
    final email = others.first.email.trim();
    if (email.isNotEmpty) return email;
    return userFallback;
  }
  final names = others
      .map((p) {
        final name = p.displayname.trim();
        return name.isNotEmpty ? name : p.email.split('@').first;
      })
      .where((n) => n.isNotEmpty)
      .take(3)
      .join(', ');
  return names.isEmpty ? groupFallback : names;
}

enum _AddMenuAction { addFriend, createGroup }

class _ChatsHeader extends StatelessWidget {
  const _ChatsHeader({
    required this.searching,
    required this.searchController,
    required this.searchHint,
    required this.searchTooltip,
    required this.addTooltip,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onAdd,
  });

  final bool searching;
  final TextEditingController searchController;
  final String searchHint;
  final String searchTooltip;
  final String addTooltip;
  final VoidCallback onToggleSearch;
  final VoidCallback onSearchChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _headerBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: searching
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          autofocus: true,
                          onChanged: (_) => onSearchChanged(),
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: searchHint,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onToggleSearch,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                        ),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: SvgPicture.asset(
                          'assets/logo/chat.svg',
                          height: 36,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: searchTooltip,
                        onPressed: onToggleSearch,
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: addTooltip,
                        onPressed: onAdd,
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _EmptyChatsState extends StatelessWidget {
  const _EmptyChatsState({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onStartChat,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStartChat,
              icon: const Icon(Icons.add),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(backgroundColor: _accentBlue),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.others,
    required this.userFallback,
    required this.groupFallback,
    required this.noMessagePreview,
  });

  final ChatEntity chat;
  final List<ProfileEntity> others;
  final String userFallback;
  final String groupFallback;
  final String noMessagePreview;

  @override
  Widget build(BuildContext context) {
    final displayName = _chatTitle(
      chat,
      others,
      userFallback: userFallback,
      groupFallback: groupFallback,
    );
    final timeLabel = formatChatTimestamp(chat.lastMessageAt);
    final photoUrl = others.length == 1 ? others.first.photoUrl : '';
    final preview = chat.lastMessage ?? noMessagePreview;

    return InkWell(
      onTap: () => context.push(AppRoutePath.chatDetail(chat.chatId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE3F2FD),
              backgroundImage:
                  photoUrl.trim().isNotEmpty ? NetworkImage(photoUrl) : null,
              child: photoUrl.trim().isEmpty
                  ? Text(
                      _getInitial(displayName),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _headerBlue,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (timeLabel.isNotEmpty)
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}
