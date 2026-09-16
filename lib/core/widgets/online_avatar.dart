import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avatar avec pastille de présence (style messagerie pro).
class OnlineAvatar extends StatelessWidget {
  const OnlineAvatar({
    super.key,
    required this.radius,
    this.photoUrl = '',
    this.initials = '?',
    this.isOnline = false,
    this.showPresence = true,
    this.backgroundColor,
    this.foregroundColor,
    this.child,
  });

  final double radius;
  final String photoUrl;
  final String initials;
  final bool isOnline;
  final bool showPresence;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Remplace l’avatar par défaut (ex. icône groupe).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl.trim().isNotEmpty;
    final size = radius * 2;
    final dot = (radius * 0.38).clamp(8.0, 14.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: child ??
                CircleAvatar(
                  radius: radius,
                  backgroundColor:
                      backgroundColor ?? AppColors.brandSurfaceAlt,
                  backgroundImage:
                      hasPhoto ? NetworkImage(photoUrl.trim()) : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          initials.isNotEmpty
                              ? initials[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: foregroundColor ?? AppColors.headerBlue,
                            fontSize: radius * 0.7,
                          ),
                        ),
                ),
          ),
          if (showPresence)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.online : AppColors.offline,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
