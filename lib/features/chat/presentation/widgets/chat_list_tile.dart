import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/chat_entity.dart';
import '../utils/chat_display.dart';

/// Ligne de conversation (1-1 ou groupe) dans la liste Chats.
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.others,
    required this.currentUserId,
    required this.userFallback,
    required this.groupFallback,
    required this.noMessagePreview,
    this.yesterdayLabel = 'Yesterday',
    this.weekdayLabels,
    this.leadingIsGroup = false,
  });

  factory ChatListTile.fromData({
    Key? key,
    required ChatEntity chat,
    required List<ProfileEntity> profiles,
    required String currentUserId,
    required AppStrings strings,
    bool leadingIsGroup = false,
  }) {
    return ChatListTile(
      key: key,
      chat: chat,
      others: findOtherProfiles(
        participantIds: chat.participantIds,
        currentUserId: currentUserId,
        profiles: profiles,
      ),
      currentUserId: currentUserId,
      userFallback: strings.userFallback,
      groupFallback: strings.groupFallback,
      noMessagePreview: strings.noMessagePreview,
      yesterdayLabel: strings.yesterday,
      weekdayLabels: strings.weekdayShort,
      leadingIsGroup: leadingIsGroup,
    );
  }

  final ChatEntity chat;
  final List<ProfileEntity> others;
  final String currentUserId;
  final String userFallback;
  final String groupFallback;
  final String noMessagePreview;
  final String yesterdayLabel;
  final List<String>? weekdayLabels;
  final bool leadingIsGroup;

  @override
  Widget build(BuildContext context) {
    final displayName = chatDisplayTitle(
      others,
      chatName: chat.name,
      emptyFallback:
          chat.participantIds.length > 2 ? groupFallback : userFallback,
      multiFallback: groupFallback,
    );
    final timeLabel = formatChatTimestamp(
      chat.lastMessageAt,
      yesterdayLabel: yesterdayLabel,
      weekdayLabels: weekdayLabels,
    );
    final photoUrl = others.length == 1 ? others.first.photoUrl : '';
    final preview = chat.lastMessage ?? noMessagePreview;
    final colors = Theme.of(context).colorScheme;
    final unread = chat.unreadFor(currentUserId);
    final hasUnread = unread > 0;
    final unreadLabel = unread > 99 ? '99+' : '$unread';

    return InkWell(
      onTap: () => context.push(AppRoutePath.chatDetail(chat.chatId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIsGroup)
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.brand.withValues(alpha: 0.15),
                child: const Icon(Icons.groups, color: AppColors.brand),
              )
            else
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.brandSurfaceAlt,
                backgroundImage:
                    photoUrl.trim().isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.trim().isEmpty
                    ? Text(
                        nameInitial(displayName),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headerBlue,
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
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (timeLabel.isNotEmpty)
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: hasUnread
                                ? AppColors.brand
                                : colors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Illustration vide pour la recherche d'utilisateurs.
class SearchEmptyIllustration extends StatelessWidget {
  const SearchEmptyIllustration({
    super.key,
    required this.message,
    this.size = 180,
  });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logo/Card Search.svg',
              width: size,
              height: size,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
