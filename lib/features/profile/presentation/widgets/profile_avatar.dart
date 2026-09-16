import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Avatar circulaire avec bouton édition / loader upload + présence.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageProvider,
    required this.isUploading,
    required this.onTap,
    this.isOnline = false,
  });

  final ImageProvider<Object> imageProvider;
  final bool isUploading;
  final VoidCallback onTap;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandLight, width: 3),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: AppColors.brand,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.online : AppColors.offline,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
