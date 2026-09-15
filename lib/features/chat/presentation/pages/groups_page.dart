import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/widgets/app_logo_header.dart';
import '../../../../core/widgets/empty_list_placeholder.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_display.dart';
import '../widgets/chat_list_tile.dart';

/// Liste des chats multi-participants (groupes).
class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(appStringsProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(s.sessionRequired)));
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AppLogoHeader(
            actions: [
              IconButton(
                tooltip: s.createGroup,
                onPressed: () => context.push(AppRoutePath.createGroupPath),
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: chatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (chats) {
                final groups = chats
                    .where((c) => c.participantIds.length > 2)
                    .toList();

                if (groups.isEmpty) {
                  return EmptyListPlaceholder(
                    icon: Icons.groups_outlined,
                    title: s.emptyGroupsTitle,
                    subtitle: s.emptyGroupsSubtitle,
                    buttonLabel: s.createGroup,
                    onAction: () => context.push(AppRoutePath.createGroupPath),
                  );
                }

                return profilesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                  data: (profiles) {
                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final chat = groups[index];
                        final others = findOtherProfiles(
                          participantIds: chat.participantIds,
                          currentUserId: user.id,
                          profiles: profiles,
                        );
                        return ChatListTile(
                          chat: chat,
                          others: others,
                          userFallback: s.groupFallback,
                          groupFallback: s.groupFallback,
                          noMessagePreview: s.noMessagePreview,
                          yesterdayLabel: s.yesterday,
                          weekdayLabels: s.weekdayShort,
                          leadingIsGroup: true,
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
}
