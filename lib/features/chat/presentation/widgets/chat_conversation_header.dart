import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/online_avatar.dart';
import 'round_icon_button.dart';

/// En-tête conversation : retour, titre, avatar + présence, menu infos.
class ChatConversationHeader extends StatelessWidget {
  const ChatConversationHeader({
    super.key,
    required this.pageTitle,
    required this.peerTitle,
    required this.peerSubtitle,
    required this.photoUrl,
    required this.closeLabel,
    required this.onBack,
    this.isOnline = false,
    this.showPresence = false,
    this.subtitleIsOnline = false,
  });

  final String pageTitle;
  final String peerTitle;
  final String peerSubtitle;
  final String photoUrl;
  final String closeLabel;
  final VoidCallback onBack;
  final bool isOnline;
  final bool showPresence;
  final bool subtitleIsOnline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back, onTap: onBack),
                Expanded(
                  child: Text(
                    pageTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                RoundIconButton(
                  icon: Icons.more_horiz,
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (sheetContext) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: OnlineAvatar(
                                  radius: 20,
                                  photoUrl: photoUrl,
                                  initials: peerTitle,
                                  isOnline: isOnline,
                                  showPresence: showPresence,
                                ),
                                title: Text(peerTitle),
                                subtitle: peerSubtitle.isEmpty
                                    ? null
                                    : Text(
                                        peerSubtitle,
                                        style: TextStyle(
                                          color: subtitleIsOnline
                                              ? AppColors.online
                                              : null,
                                          fontWeight: subtitleIsOnline
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.close),
                                title: Text(closeLabel),
                                onTap: () => Navigator.pop(sheetContext),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                OnlineAvatar(
                  radius: 24,
                  photoUrl: photoUrl,
                  initials: peerTitle,
                  isOnline: isOnline,
                  showPresence: showPresence,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peerTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      if (peerSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          peerSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: subtitleIsOnline
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: subtitleIsOnline
                                ? AppColors.online
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
        ],
      ),
    );
  }
}
