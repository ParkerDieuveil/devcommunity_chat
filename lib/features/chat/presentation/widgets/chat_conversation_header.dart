import 'package:flutter/material.dart';

import 'round_icon_button.dart';

/// En-tête conversation : retour, titre, avatar, menu infos.
class ChatConversationHeader extends StatelessWidget {
  const ChatConversationHeader({
    super.key,
    required this.pageTitle,
    required this.peerTitle,
    required this.peerSubtitle,
    required this.photoUrl,
    required this.closeLabel,
    required this.onBack,
  });

  final String pageTitle;
  final String peerTitle;
  final String peerSubtitle;
  final String photoUrl;
  final String closeLabel;
  final VoidCallback onBack;

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
                RoundIconButton(
                  icon: Icons.arrow_back,
                  onTap: onBack,
                ),
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
                                leading: const Icon(Icons.info_outline),
                                title: Text(peerTitle),
                                subtitle: peerSubtitle.isEmpty
                                    ? null
                                    : Text(peerSubtitle),
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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: photoUrl.trim().isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.trim().isEmpty
                      ? Text(
                          peerTitle.isNotEmpty
                              ? peerTitle[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
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
                            color: colors.onSurfaceVariant,
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
