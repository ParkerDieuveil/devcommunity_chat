import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Grille de pièces jointes réellement supportées (caméra, micro, galerie).
class ChatAttachmentPanel extends StatelessWidget {
  const ChatAttachmentPanel({
    super.key,
    required this.enabled,
    required this.cameraLabel,
    required this.recordLabel,
    required this.galleryLabel,
    required this.onCamera,
    required this.onRecord,
    required this.onGallery,
  });

  final bool enabled;
  final String cameraLabel;
  final String recordLabel;
  final String galleryLabel;
  final VoidCallback onCamera;
  final VoidCallback onRecord;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final panelBg = isDark ? AppColors.navBarDark : colors.surface;
    final tileBg = isDark
        ? colors.primary.withValues(alpha: 0.18)
        : AppColors.brandSurface;
    final labelColor = colors.onSurfaceVariant;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderPanelLight;

    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.photo_camera_outlined, label: cameraLabel, onTap: onCamera),
      (icon: Icons.mic_none_rounded, label: recordLabel, onTap: onRecord),
      (icon: Icons.image_outlined, label: galleryLabel, onTap: onGallery),
    ];

    return Container(
      width: double.infinity,
      color: panelBg,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: enabled ? item.onTap : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: tileBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: AppColors.brand,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: labelColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
