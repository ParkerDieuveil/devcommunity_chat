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

/// Liste des chats multi-participants (groupes).
class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(appStringsProvider);

    if (user == null) {
      return Scaffold(
        body: Center(child: Text(s.sessionRequired)),
      );
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          ColoredBox(
            color: _headerBlue,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Padding(
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
                        tooltip: s.createGroup,
                        onPressed: () =>
                            context.push(AppRoutePath.createGroupPath),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.emptyGroupsTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.emptyGroupsSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () =>
                                context.push(AppRoutePath.createGroupPath),
                            icon: const Icon(Icons.add),
                            label: Text(s.createGroup),
                            style: FilledButton.styleFrom(
                              backgroundColor: _accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        final others = _others(chat, user.id, profiles);
                        final title = _groupTitle(others, s);
                        final time = formatChatTimestamp(chat.lastMessageAt);
                        final preview =
                            chat.lastMessage ?? s.noMessagePreview;

                        return InkWell(
                          onTap: () => context.push(
                            AppRoutePath.chatDetail(chat.chatId),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      _accentBlue.withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons.groups,
                                    color: _accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (time.isNotEmpty)
                                            Text(
                                              time,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
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
                                          color: Colors.grey.shade600,
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

  List<ProfileEntity> _others(
    ChatEntity chat,
    String currentUserId,
    List<ProfileEntity> profiles,
  ) {
    final result = <ProfileEntity>[];
    for (final id in chat.participantIds) {
      if (id == currentUserId) continue;
      for (final p in profiles) {
        if (p.id == id) {
          result.add(p);
          break;
        }
      }
    }
    return result;
  }

  String _groupTitle(List<ProfileEntity> others, AppStrings s) {
    if (others.isEmpty) return s.groupFallback;
    final names = others
        .map((p) {
          final name = p.displayname.trim();
          return name.isNotEmpty ? name : p.email.split('@').first;
        })
        .where((n) => n.isNotEmpty)
        .take(3)
        .join(', ');
    return names.isEmpty ? s.groupFallback : names;
  }
}
