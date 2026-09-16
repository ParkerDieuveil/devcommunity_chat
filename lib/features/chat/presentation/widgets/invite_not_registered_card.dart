import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// État vide quand la recherche ne trouve aucun compte inscrit.
class InviteNotRegisteredCard extends StatelessWidget {
  const InviteNotRegisteredCard({
    super.key,
    required this.query,
    required this.strings,
  });

  final String query;
  final AppStrings strings;

  Future<void> _copyInvite(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: strings.inviteMessage(query)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.inviteCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.brandSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brand.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 34,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.userNotRegistered,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _copyInvite(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(strings.inviteFriend),
            ),
          ],
        ),
      ),
    );
  }
}
