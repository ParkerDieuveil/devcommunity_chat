import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/widgets/empty_list_placeholder.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_display.dart';
import '../widgets/chat_add_menu.dart';
import '../widgets/chat_list_tile.dart';
import '../widgets/chats_header.dart';

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
    final action = await showChatAddMenu(
      context,
      addContactLabel: s.addContact,
      createGroupLabel: s.createGroup,
    );

    if (!mounted || action == null) return;

    switch (action) {
      case ChatAddMenuAction.addFriend:
        context.push(AppRoutePath.newChatPath);
      case ChatAddMenuAction.createGroup:
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
          ChatsHeader(
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: chatsAsync.when(
                loading: () => const Center(
                  key: ValueKey('chats-loading'),
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  key: const ValueKey('chats-error'),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                ),
                data: (chats) {
                  if (chats.isEmpty) {
                    return EmptyListPlaceholder(
                      key: const ValueKey('chats-empty'),
                      icon: Icons.forum_outlined,
                      title: s.emptyChatsTitle,
                      subtitle: s.emptyChatsSubtitle,
                      buttonLabel: s.newChat,
                      onAction: _openAddMenu,
                    );
                  }

                  return profilesAsync.when(
                    loading: () => const Center(
                      key: ValueKey('chats-profiles-loading'),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => Center(
                      key: const ValueKey('chats-profiles-error'),
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
                        final other = findOtherProfiles(
                          participantIds: chat.participantIds,
                          currentUserId: user.id,
                          profiles: profiles,
                        );
                        final name = chatDisplayTitle(
                          other,
                          chatName: chat.name,
                          emptyFallback: chat.participantIds.length > 2
                              ? s.groupFallback
                              : s.userFallback,
                          multiFallback: s.groupFallback,
                        ).toLowerCase();
                        final last = (chat.lastMessage ?? '').toLowerCase();
                        return name.contains(query) || last.contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          key: const ValueKey('chats-no-results'),
                          child: Text(s.noChatsFound),
                        );
                      }

                      return ListView.builder(
                        key: const ValueKey('chats-list'),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final chat = filtered[index];
                          final others = findOtherProfiles(
                            participantIds: chat.participantIds,
                            currentUserId: user.id,
                            profiles: profiles,
                          );
                          return ChatListTile(
                            chat: chat,
                            others: others,
                            currentUserId: user.id,
                            userFallback: s.userFallback,
                            groupFallback: s.groupFallback,
                            noMessagePreview: s.noMessagePreview,
                            yesterdayLabel: s.yesterday,
                            weekdayLabels: s.weekdayShort,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
