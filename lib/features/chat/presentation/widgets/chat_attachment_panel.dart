import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Grille de pièces jointes (caméra, micro, galerie, stubs…).
class ChatAttachmentPanel extends StatelessWidget {
  const ChatAttachmentPanel({
    super.key,
    required this.enabled,
    required this.cameraLabel,
    required this.recordLabel,
    required this.contactLabel,
    required this.galleryLabel,
    required this.locationLabel,
    required this.documentLabel,
    required this.onCamera,
    required this.onRecord,
    required this.onContact,
    required this.onGallery,
    required this.onLocation,
    required this.onDocument,
  });

  final bool enabled;
  final String cameraLabel;
  final String recordLabel;
  final String contactLabel;
  final String galleryLabel;
  final String locationLabel;
  final String documentLabel;
  final VoidCallback onCamera;
  final VoidCallback onRecord;
  final VoidCallback onContact;
  final VoidCallback onGallery;
  final VoidCallback onLocation;
  final VoidCallback onDocument;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? const Color(0xFF121826) : Colors.white;
    final tileBg = isDark
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
        : AppColors.brandSurface;
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.photo_camera_outlined, label: cameraLabel, onTap: onCamera),
      (icon: Icons.mic_none_rounded, label: recordLabel, onTap: onRecord),
      (icon: Icons.person_outline, label: contactLabel, onTap: onContact),
      (icon: Icons.image_outlined, label: galleryLabel, onTap: onGallery),
      (
        icon: Icons.location_on_outlined,
        label: locationLabel,
        onTap: onLocation,
      ),
      (
        icon: Icons.description_outlined,
        label: documentLabel,
        onTap: onDocument,
      ),
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
          border: Border.all(
            color: isDark ? const Color(0xFF263041) : const Color(0xFFEEF1F5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: [
              for (final item in items)
                InkWell(
                  onTap: enabled ? item.onTap : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: tileBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: AppColors.brand, size: 26),
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
            ],
          ),
        ),
      ),
    );
  }
}
