import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Barre bleue avec logo (et actions optionnelles à droite).
class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.headerBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: SvgPicture.asset(
                    'assets/logo/chat.svg',
                    height: 36,
                  ),
                ),
                if (actions != null) ...[
                  const Spacer(),
                  ...actions!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
