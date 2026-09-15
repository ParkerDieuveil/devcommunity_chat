import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// Barre de saisie + bouton + / envoi.
class ChatMessageInputBar extends StatelessWidget {
  const ChatMessageInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.attachmentsOpen,
    required this.messageHint,
    required this.attachmentsTooltip,
    required this.onToggleAttachments,
    required this.onSend,
    required this.onFieldTap,
  });

  final TextEditingController controller;
  final bool sending;
  final bool attachmentsOpen;
  final String messageHint;
  final String attachmentsTooltip;
  final VoidCallback onToggleAttachments;
  final VoidCallback onSend;
  final VoidCallback onFieldTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final inputBarBg = isDark ? AppColors.navBarDark : Colors.white;

    return SafeArea(
      top: false,
      child: Container(
        color: inputBarBg,
        padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
        child: Row(
          children: [
            IconButton(
              onPressed: sending ? null : onToggleAttachments,
              tooltip: attachmentsTooltip,
              icon: Icon(
                attachmentsOpen ? Icons.close : Icons.add,
                color: AppColors.brand,
                size: 28,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !sending,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                onTap: onFieldTap,
                decoration: InputDecoration(
                  hintText: messageHint,
                  hintStyle: TextStyle(color: colors.onSurfaceVariant),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: SizedBox(
                width: 52,
                height: 52,
                child: sending
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brand,
                          ),
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/logo/Button Md.svg',
                        width: 52,
                        height: 52,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
