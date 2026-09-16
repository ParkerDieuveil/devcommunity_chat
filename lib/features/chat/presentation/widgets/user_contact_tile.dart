import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/online_avatar.dart';
import '../utils/chat_display.dart';

/// Tuile contact (recherche new chat).
class UserContactTile extends StatelessWidget {
  const UserContactTile({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.loading,
    required this.startChatTooltip,
    required this.onTap,
    this.isOnline = false,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final bool loading;
  final String startChatTooltip;
  final VoidCallback onTap;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim().isEmpty ? email : displayName;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: OnlineAvatar(
        radius: 24,
        photoUrl: photoUrl,
        initials: nameInitial(name),
        isOnline: isOnline,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: onTap,
              tooltip: startChatTooltip,
              icon: SvgPicture.asset(
                'assets/logo/User Plus.svg',
                width: 24,
                height: 24,
              ),
            ),
      onTap: loading ? null : onTap,
    );
  }
}
